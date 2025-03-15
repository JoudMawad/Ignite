import SwiftUI
import CoreData

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    // Separate published property to force immediate UI updates for the calorie goal.
    @Published var dailyCalorieGoalValue: Int = 1500
    
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
            let newGoal = Int(profile.dailyCalorieGoal)
            if newGoal != dailyCalorieGoalValue {
                DispatchQueue.main.async {
                    self.dailyCalorieGoalValue = newGoal
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
    
    var currentWeight: Double {
        get { profile?.currentWeight ?? 70.0 }
        set {
            profile?.currentWeight = newValue
            saveProfile()
        }
    }
    
    var startWeight: Double {
        get { profile?.startWeight ?? 70.0 }
        set {
            profile?.startWeight = newValue
            saveProfile()
        }
    }
    
    var goalWeight: Double {
        get { profile?.goalWeight ?? 65.0 }
        set {
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
        get { Int(profile?.dailyStepsGoal ?? 10000) }
        set {
            profile?.dailyStepsGoal = Int32(newValue)
            saveProfile()
        }
    }
    
    var dailyBurnedCaloriesGoal: Int {
        get { Int(profile?.dailyBurnedCaloriesGoal ?? 500) }
        set {
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
