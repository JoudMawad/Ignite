import SwiftUI
import CoreData

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    // Separate published property to force immediate UI updates for the calorie goal.
    @Published var dailyCalorieGoalValue: Int = 1500
    @Published var dailyStepsGoalValue: Int = 10000
    @Published var dailyBurnedCaloriesGoalValue: Int = 500
    @Published var startWeightValue: Double = 70.0
    @Published var currentWeightValue: Double = 70.0
    @Published var goalWeightValue: Double = 65.0


    
    // Existing managers.
    private let weightHistoryManager = WeightHistoryManager.shared
    private let weightManager = WeightManager()
    private var reimportWorkItem: DispatchWorkItem?
    
    // Shared Core Data context.
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfile()
        // Observe Core Data context changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextObjectsDidChange(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Listen for Core Data changes and update our published goal if necessary.
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        if let profile = profile {
            // Update calorie goal (already handled)...
            let newCalorieGoal = Int(profile.dailyCalorieGoal)
            if newCalorieGoal != dailyCalorieGoalValue {
                DispatchQueue.main.async {
                    self.dailyCalorieGoalValue = newCalorieGoal
                }
            }
            
            // Update steps goal (already handled)...
            let newStepsGoal = Int(profile.dailyStepsGoal)
            if newStepsGoal != dailyStepsGoalValue {
                DispatchQueue.main.async {
                    self.dailyStepsGoalValue = newStepsGoal
                }
            }
            
            // Update burned calories goal:
            let newBurnedGoal = Int(profile.dailyBurnedCaloriesGoal)
            if newBurnedGoal != dailyBurnedCaloriesGoalValue {
                DispatchQueue.main.async {
                    self.dailyBurnedCaloriesGoalValue = newBurnedGoal
                }
            }
            
            let newStartWeight = profile.startWeight
            if newStartWeight != startWeightValue {
                DispatchQueue.main.async {
                    self.startWeightValue = newStartWeight
                }
            }
                
            let newCurrentWeight = profile.currentWeight
            if newCurrentWeight != currentWeightValue {
                DispatchQueue.main.async {
                    self.currentWeightValue = newCurrentWeight
                }
            }
                  
            let newGoalWeight = profile.goalWeight
            if newGoalWeight != goalWeightValue {
                DispatchQueue.main.async {
                    self.goalWeightValue = newGoalWeight
                }
            }
        }
    }


    
    @objc private func handleHealthKitDataChange() {
        reimportWorkItem?.cancel()
        reimportWorkItem = DispatchWorkItem { [weak self] in
            self?.importHistoricalWeightsFromHealthKit()
            self?.updateWeightFromHealthKit()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: reimportWorkItem!)
    }
    
    func loadProfile() {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            if let existingProfile = profiles.first {
                DispatchQueue.main.async {
                    self.profile = existingProfile
                    self.dailyCalorieGoalValue = Int(existingProfile.dailyCalorieGoal)
                }
            } else {
                // Create a new profile with default values.
                let newProfile = UserProfile(context: context)
                newProfile.name = ""
                newProfile.gender = ""
                newProfile.age = 0
                newProfile.height = 0
                newProfile.dailyCalorieGoal = 1500
                newProfile.dailyStepsGoal = 0
                newProfile.startWeight = 0.0
                newProfile.currentWeight = 0.0
                newProfile.goalWeight = 0.0
                newProfile.profileImageData = nil
                try context.save()
                DispatchQueue.main.async {
                    self.profile = newProfile
                    self.dailyCalorieGoalValue = 1500
                }
            }
        } catch {
            print("Error loading profile: \(error)")
        }
    }
    
    func saveProfile() {
        do {
            try context.save()
        } catch {
            print("Error saving profile: \(error)")
        }
    }
    
    func updateCurrentWeight(_ newWeight: Double) {
        DispatchQueue.main.async {
            if let profile = self.profile {
                profile.currentWeight = newWeight
                self.saveProfile()
                // Save today's weight in Core Data.
                WeightHistoryManager.shared.saveWeight(for: Date(), weight: newWeight)
            }
        }
    }
    
    func updateWeightFromHealthKit() {
        weightManager.fetchLatestWeight { [weak self] result in
            guard let self = self, let newData = result else { return }
            let newWeight = newData.weight
            let newSampleDate = newData.date

            let todayEntries = self.weightHistoryManager.weightForPeriod(days: 1)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            var storedDate: Date? = nil
            if let entry = todayEntries.first, let dateFromString = formatter.date(from: entry.date) {
                storedDate = dateFromString
            }
            
            DispatchQueue.main.async {
                if storedDate == nil || newSampleDate > storedDate! {
                    self.updateCurrentWeight(newWeight)
                }
            }
        }
    }
    
    func importHistoricalWeightsFromHealthKit() {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        weightManager.fetchHistoricalDailyWeights(startDate: oneYearAgo, endDate: Date()) { [weak self] dailyWeights in
            DispatchQueue.main.async {
                self?.weightHistoryManager.importHistoricalWeights(dailyWeights)
            }
        }
    }
    
    // MARK: - Computed Properties for Binding
    
    var name: String {
        get { profile?.name ?? "" }
        set {
            profile?.name = newValue
            saveProfile()
        }
    }
    
    var firstName: String {
        let parts = name.split(separator: " ")
        return parts.first.map(String.init) ?? ""
    }
    
    var age: Int {
        get { Int(profile?.age ?? 25) }
        set {
            profile?.age = Int32(newValue)
            saveProfile()
        }
    }
    
    var height: Int {
        get { Int(profile?.height ?? 170) }
        set {
            profile?.height = Int32(newValue)
            saveProfile()
        }
    }
    
    var startWeight: Double {
        get { startWeightValue }
        set {
            objectWillChange.send()
            startWeightValue = newValue
            profile?.startWeight = newValue
            saveProfile()
        }
    }

    var currentWeight: Double {
        get { currentWeightValue }
        set {
            objectWillChange.send()
            currentWeightValue = newValue
            profile?.currentWeight = newValue
            saveProfile()
        }
    }

    var goalWeight: Double {
        get { goalWeightValue }
        set {
            objectWillChange.send()
            goalWeightValue = newValue
            profile?.goalWeight = newValue
            saveProfile()
        }
    }
    
    // Use the separate published property to force immediate updates.
    var dailyCalorieGoal: Int {
        get { dailyCalorieGoalValue }
        set {
            objectWillChange.send()
            dailyCalorieGoalValue = newValue
            profile?.dailyCalorieGoal = Int32(newValue)
            saveProfile()
        }
    }
    
    var dailyStepsGoal: Int {
        get { dailyStepsGoalValue }
        set {
            objectWillChange.send()  // Notify immediately.
            dailyStepsGoalValue = newValue
            profile?.dailyStepsGoal = Int32(newValue)
            saveProfile()
        }
    }



    
    var dailyBurnedCaloriesGoal: Int {
        get { dailyBurnedCaloriesGoalValue }
        set {
            objectWillChange.send()
            dailyBurnedCaloriesGoalValue = newValue
            profile?.dailyBurnedCaloriesGoal = Int32(newValue)
            saveProfile()
        }
    }

    
    var gender: String {
        get { profile?.gender ?? "Male" }
        set {
            profile?.gender = newValue
            saveProfile()
        }
    }
}
