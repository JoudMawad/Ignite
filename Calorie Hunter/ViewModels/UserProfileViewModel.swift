import SwiftUI
import CoreData

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
    
    // Published properties for various goals and weight values.
    // Using separate properties ensures that UI updates immediately when these values change.
    @Published var dailyCalorieGoalValue: Int = 1500
    @Published var dailyStepsGoalValue: Int = 10000
    @Published var dailyBurnedCaloriesGoalValue: Int = 500
    @Published var dailyWaterGoalValue: Double = 2.0
    @Published var startWeightValue: Double = 70.0
    @Published var currentWeightValue: Double = 70.0
    @Published var goalWeightValue: Double = 65.0
    /// User’s weekly weight change goal (kg per week; negative to lose, positive to gain)
    @Published var weeklyWeightChangeGoalValue: Double = 0.0
    /// User’s activity level as an integer (0=sedentary…3=veryActive)
    @Published var activityLevelValue: Int = 0

    // Managers to handle weight history and HealthKit weight updates.
    private let weightHistoryManager = WeightHistoryManager.shared
    private let weightManager = WeightManager()
    // A DispatchWorkItem to manage delayed re-imports when HealthKit data changes.
    private var reimportWorkItem: DispatchWorkItem?
    
    // The Core Data context for fetching and saving the user profile.
    private var context: NSManagedObjectContext
    /// Manager for daily goal history.
    private let goalsManager = GoalsManager.shared

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
            blank.dailyCalorieGoal     = 0
            blank.dailyStepsGoal       = 0
            blank.dailyBurnedCaloriesGoal = 0
            blank.dailyWaterGoal       = 0.0

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
            // Update daily calorie goal if it has changed.
            let newCalorieGoal = Int(profile.dailyCalorieGoal)
            if newCalorieGoal != dailyCalorieGoalValue {
                DispatchQueue.main.async {
                    self.dailyCalorieGoalValue = newCalorieGoal
                }
            }

            // Update daily steps goal if needed.
            let newStepsGoal = Int(profile.dailyStepsGoal)
            if newStepsGoal != dailyStepsGoalValue {
                DispatchQueue.main.async {
                    self.dailyStepsGoalValue = newStepsGoal
                }
            }

            // Update daily burned calories goal.
            let newBurnedGoal = Int(profile.dailyBurnedCaloriesGoal)
            if newBurnedGoal != dailyBurnedCaloriesGoalValue {
                DispatchQueue.main.async {
                    self.dailyBurnedCaloriesGoalValue = newBurnedGoal
                }
            }

            // Update daily water goal if it has changed.
            let newWaterGoal = profile.dailyWaterGoal
            if newWaterGoal != dailyWaterGoalValue {
                DispatchQueue.main.async {
                    self.dailyWaterGoalValue = newWaterGoal
                }
            }

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
                    self.currentWeightValue = newCurrentWeight
                }
            }

            // Update goal weight.
            let newGoalWeight = profile.goalWeight
            if newGoalWeight != goalWeightValue {
                DispatchQueue.main.async {
                    self.goalWeightValue = newGoalWeight
                }
            }

            // Update weekly weight change goal.
            let newWeeklyChange = profile.weeklyWeightChangeGoal
            if newWeeklyChange != weeklyWeightChangeGoalValue {
                DispatchQueue.main.async {
                    self.weeklyWeightChangeGoalValue = newWeeklyChange
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
                    // Initialize goals for today based on stored profile values
                    self.goalsManager.updateGoal(Double(existingProfile.dailyCalorieGoal), for: GoalType.calories, on: Date())
                    self.goalsManager.updateGoal(Double(existingProfile.dailyStepsGoal), for: GoalType.steps, on: Date())
                    self.goalsManager.updateGoal(Double(existingProfile.dailyBurnedCaloriesGoal), for: GoalType.burnedCalories, on: Date())
                    self.dailyWaterGoalValue = existingProfile.dailyWaterGoal
                    // sync weights into your @Published state
                    self.startWeightValue   = existingProfile.startWeight
                    self.currentWeightValue = existingProfile.currentWeight
                    self.goalWeightValue    = existingProfile.goalWeight
                    self.weeklyWeightChangeGoalValue = existingProfile.weeklyWeightChangeGoal
                    self.activityLevelValue = Int(existingProfile.activityLevel)
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
            print("✅ Profile saved")
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
                // Save today's weight in Core Data for weight history tracking.
                WeightHistoryManager.shared.saveWeight(for: Date(), weight: newWeight)
            }
        }
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
                    self.updateCurrentWeight(newWeight)
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

    /// Returns and sets the user's goal weight.
    var goalWeight: Double {
        get { goalWeightValue }
        set {
            objectWillChange.send()
            goalWeightValue = newValue
            profile?.goalWeight = newValue
            scheduleSave()
        }
    }
    
    /// Returns and sets the user's daily calorie goal.
    var dailyCalorieGoal: Int {
        get { dailyCalorieGoalValue }
        set {
            objectWillChange.send()
            dailyCalorieGoalValue = newValue
            profile?.dailyCalorieGoal = Int32(newValue)
            scheduleSave()
        }
    }
    
    /// Returns and sets the user's daily steps goal.
    var dailyStepsGoal: Int {
        get { dailyStepsGoalValue }
        set {
            objectWillChange.send()
            dailyStepsGoalValue = newValue
            profile?.dailyStepsGoal = Int32(newValue)
            scheduleSave()
        }
    }
    
    /// Returns and sets the user's daily burned calories goal.
    var dailyBurnedCaloriesGoal: Int {
        get { dailyBurnedCaloriesGoalValue }
        set {
            objectWillChange.send()
            dailyBurnedCaloriesGoalValue = newValue
            profile?.dailyBurnedCaloriesGoal = Int32(newValue)
            scheduleSave()
        }
    }
    
    /// Returns and sets the user's daily water goal.
    var dailyWaterGoal: Double {
        get { dailyWaterGoalValue }
        set {
            objectWillChange.send()
            dailyWaterGoalValue = newValue
            profile?.dailyWaterGoal = newValue
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

    /// Returns and sets the user's weekly weight change goal (kg/week).
    var weeklyWeightChangeGoal: Double {
        get { weeklyWeightChangeGoalValue }
        set {
            objectWillChange.send()
            weeklyWeightChangeGoalValue = newValue
            profile?.weeklyWeightChangeGoal = newValue
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
}
