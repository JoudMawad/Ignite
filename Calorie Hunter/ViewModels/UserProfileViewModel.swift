import SwiftUI
import CoreData
import Combine

// UserProfileViewModel is responsible for managing the user's profile data,
// including personal details, goals, and weight information.
// It loads and saves profile data from Core Data and listens to HealthKit updates.
class UserProfileViewModel: ObservableObject {
    // Debounce helper for auto-saving
    private var saveWorkItem: DispatchWorkItem?
    private func scheduleSave() {
        // Cancel any pending save
        saveWorkItem?.cancel()
        // Create a new work item to perform the save after a short delay
        let item = DispatchWorkItem { [weak self] in
            self?.saveProfile()
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }
    // Published property for the entire user profile.
    @Published var profile: UserProfile?
    
    // Published properties for weight and activity information.
    // Using separate properties ensures that UI updates immediately when these values change.
    @Published var startWeightValue: Double = 70.0
    @Published var currentWeightValue: Double = 70.0
    /// User’s activity level as an integer (0=sedentary…3=veryActive)
    @Published var activityLevelValue: Int = 0

    // Managers to handle weight history and HealthKit weight updates.
    private let weightHistoryManager = WeightHistoryManager.shared
    private let weightManager = WeightManager()
    // A DispatchWorkItem to manage delayed re-imports when HealthKit data changes.
    private var reimportWorkItem: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()
    private var suppressWeightAutoSave = false
    
    // The Core Data context for fetching and saving the user profile.
    private var context: NSManagedObjectContext

    /// Initializes the view model with a Core Data context.
    /// It loads the user profile and sets up observers for Core Data changes and HealthKit updates.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfile()
        if self.profile == nil {
            let blank = UserProfile(context: context)
            // satisfy the model’s “required” flags
            blank.name                 = ""
            blank.gender               = ""
            blank.age                  = 0
            blank.height               = 0
            blank.startWeight          = 0.0
            blank.currentWeight        = 0.0
            blank.goalWeight           = 0.0
            // Intentionally omit goal fields initialization
            do {
               try context.save()
            } catch {
               print("Error creating stub profile: \(error)")
            }
            self.profile = blank
        }
        // Observe Core Data changes so that if the profile updates, the published properties can be refreshed.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextObjectsDidChange(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context)
        // Request HealthKit authorization, then start weight monitoring and import historical weights.
        HealthKitManager.shared.requestAuthorization { [weak self] success, _ in
            guard let self = self else { return }
            if success {
                self.weightManager.startObservingWeightChanges()
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.handleHealthKitDataChange),
                                                       name: .healthKitWeightDataChanged,
                                                       object: nil)
                self.importHistoricalWeightsFromHealthKit()
                self.updateWeightFromHealthKit()
            }
        }
        // Debounce user-driven current weight edits: write to HealthKit after 5s of inactivity
        $currentWeightValue
            .dropFirst() // ignore the initial assignment when the view appears
            .removeDuplicates(by: { abs($0 - $1) < 0.0001 })
            // Snapshot whether this change was programmatic at the time it happened
            .map { [weak self] value -> (value: Double, suppressed: Bool) in
                (value, self?.suppressWeightAutoSave ?? false)
            }
            // Only allow user-driven changes through
            .filter { !$0.suppressed }
            .map { $0.value }
            .sink { newValue in
                WeightHistoryManager.shared.saveWeight(for: Date(), weight: newValue, writeToHealthKit: true)
            }
            .store(in: &cancellables)
    }
    
    // Remove observers on deinitialization to avoid memory leaks.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Core Data Change Handling
    
    /// Called when Core Data objects change.
    /// It updates the published properties if the corresponding values in the profile have changed.
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        if let profile = profile {
            // Update start weight.
            let newStartWeight = profile.startWeight
            if newStartWeight != startWeightValue {
                DispatchQueue.main.async {
                    self.startWeightValue = newStartWeight
                }
            }

            // Update current weight.
            let newCurrentWeight = profile.currentWeight
            if newCurrentWeight != currentWeightValue {
                DispatchQueue.main.async {
                    // Mute autosave so Core Data–driven refreshes don't write back to HealthKit
                    self.suppressWeightAutoSave = true
                    self.currentWeightValue = newCurrentWeight
                    // Re-enable autosave on next runloop tick
                    DispatchQueue.main.async { [weak self] in self?.suppressWeightAutoSave = false }
                }
            }
            // Update activity level.
            let newActivityLevel = Int(profile.activityLevel)
            if newActivityLevel != activityLevelValue {
                DispatchQueue.main.async {
                    self.activityLevelValue = newActivityLevel
                }
            }
        }
    }
    
    // MARK: - HealthKit Data Handling
    
    /// Handles HealthKit weight data change notifications.
    /// It schedules a re-import of historical weights and an update of the current weight after a delay.
    @objc private func handleHealthKitDataChange() {
        reimportWorkItem?.cancel()
        reimportWorkItem = DispatchWorkItem { [weak self] in
            self?.importHistoricalWeightsFromHealthKit()
            self?.updateWeightFromHealthKit()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: reimportWorkItem!)
    }
    
    func createProfile(name: String, gender: String, age: Int32, height: Int32, startWeight: Double, currentWeight: Double, goalWeight: Double, dailyGoals: (calories: Int32, steps: Int32, burned: Int32, water: Double)) {
        let p = UserProfile(context: context)
        p.name   = name
        p.gender = gender
        p.age    = age
        p.height = height
        p.startWeight               = startWeight
        p.currentWeight             = currentWeight
        p.goalWeight                = goalWeight
        p.dailyCalorieGoal          = dailyGoals.calories
        p.dailyStepsGoal            = dailyGoals.steps
        p.dailyBurnedCaloriesGoal   = dailyGoals.burned
        p.dailyWaterGoal            = dailyGoals.water
        try? context.save()
        self.profile = p
    }
    
    /// Loads the user profile from Core Data.
    /// If no profile exists, waits for the user to call createProfile(...) before saving.
    func loadProfile() {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            if let existingProfile = profiles.first {
                DispatchQueue.main.async {
                    self.profile = existingProfile
                    // ---- Begin suppression for weight-driven autosave ----
                    self.suppressWeightAutoSave = true
                    // sync weights into your @Published state
                    self.startWeightValue   = existingProfile.startWeight
                    self.currentWeightValue = existingProfile.currentWeight
                    self.activityLevelValue = Int(existingProfile.activityLevel)
                    // Re-enable autosave next runloop so user edits still get saved to HealthKit
                    DispatchQueue.main.async { [weak self] in self?.suppressWeightAutoSave = false }
                    // ---- End suppression ----
                }
            } else {
                self.profile = nil
            }
        } catch {
            print("Error loading profile: \(error)")
        }
    }
    
    /// Saves the current user profile to Core Data.
    func saveProfile() {
        // Only save if there are changes
        guard context.hasChanges else { return }
        do {
            try context.save()
            print("Profile saved")
        } catch {
            print("Error saving profile: \(error)")
        }
    }
    
    // MARK: - Weight Updates
    
    /// Updates the current weight in the profile and saves it.
    /// Also records today's weight in the weight history.
    /// - Parameter newWeight: The new current weight value.
    func updateCurrentWeight(_ newWeight: Double) {
        DispatchQueue.main.async {
            if let profile = self.profile {
                profile.currentWeight = newWeight
                self.saveProfile()
                // Save today's weight locally; do NOT echo to HealthKit here.
                WeightHistoryManager.shared.saveWeight(for: Date(), weight: newWeight, writeToHealthKit: false)
            }
        }
    }

    /// Programmatic setter for weight (e.g., when syncing from HealthKit) that avoids triggering the debounce write-back.
    func setWeightFromSystem(_ value: Double) {
        suppressWeightAutoSave = true
        if let profile = self.profile {
            profile.currentWeight = value
            self.saveProfile()
        }
        self.currentWeightValue = value
        // Re-enable autosave on the next run loop so user edits still trigger the pipeline
        DispatchQueue.main.async { [weak self] in self?.suppressWeightAutoSave = false }
    }
    
    /// Fetches the latest weight from HealthKit and updates the profile if newer data is available.
    func updateWeightFromHealthKit() {
        weightManager.fetchLatestWeight { [weak self] result in
            guard let self = self, let newData = result else { return }
            let newWeight = newData.weight
            let newSampleDate = newData.date
            
            // Get today's stored weight entry (if available) from the weight history.
            let todayEntries = self.weightHistoryManager.weightForPeriod(days: 1)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            var storedDate: Date? = nil
            if let entry = todayEntries.first, let dateFromString = formatter.date(from: entry.date) {
                storedDate = dateFromString
            }
            
            DispatchQueue.main.async {
                // If there's no stored entry or the new sample is more recent, update the current weight.
                if storedDate == nil || newSampleDate > storedDate! {
                    self.setWeightFromSystem(newWeight)
                }
            }
        }
    }
    
    /// Imports historical weight data from HealthKit and updates the weight history.
    func importHistoricalWeightsFromHealthKit() {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        weightManager.fetchHistoricalDailyWeights(startDate: oneYearAgo, endDate: Date()) { [weak self] dailyWeights in
            DispatchQueue.main.async {
                self?.weightHistoryManager.importHistoricalWeights(dailyWeights)
            }
        }
    }
    
    // MARK: - Computed Properties for Binding
    
    /// Returns the user's full name, or an empty string if not set.
    var name: String {
        get { profile?.name ?? "" }
        set {
            objectWillChange.send()
            profile?.name = newValue
            scheduleSave()
        }
    }
    
    /// Returns the first name extracted from the full name.
    var firstName: String {
        let parts = name.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    /// Returns the user's age, defaulting to 25 if not set.
    var age: Int {
        get { Int(profile?.age ?? 25) }
        set {
            objectWillChange.send()
            profile?.age = Int32(newValue)
            scheduleSave()
        }
    }
    
    /// Returns the user's height, defaulting to 170 if not set.
    var height: Int {
        get { Int(profile?.height ?? 170) }
        set {
            objectWillChange.send()
            profile?.height = Int32(newValue)
            scheduleSave()
        }
    }
    
    
    /// Returns and sets the user's gender.
    var gender: String {
        get { profile?.gender ?? "Male" }
        set {
            objectWillChange.send()
            profile?.gender = newValue
            scheduleSave()
        }
    }


    /// Returns and sets the user's activity level.
    var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelValue) ?? .sedentary }
        set {
            objectWillChange.send()
            activityLevelValue = newValue.rawValue
            profile?.activityLevel = Int32(newValue.rawValue)
            scheduleSave()
        }
    }
    
    /// Returns and sets the user's start weight.
    var startWeight: Double {
        get { startWeightValue }
        set {
            objectWillChange.send()
            startWeightValue = newValue
            profile?.startWeight = newValue
            scheduleSave()
        }
    }

    /// Returns and sets the user's current weight.
    /// Writing here updates the profile, Core Data, and HealthKit.
    var currentWeight: Double {
      get { currentWeightValue }
      set {
        // Round to 2 decimal places
        let rounded = (newValue * 100).rounded() / 100
        guard rounded != currentWeightValue else { return }
        // Push through your existing helper which writes to CoreData + HealthKit
        currentWeightValue = rounded
        updateCurrentWeight(rounded)
      }
    }
}

   
