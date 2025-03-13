import SwiftUI
import CoreData

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    
    // Existing managers.
    private let weightHistoryManager = WeightHistoryManager.shared
    private let healthKitManager = HealthKitManager.shared
    private var reimportWorkItem: DispatchWorkItem?
    
    // Using the shared context from your PersistenceController.
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfile()
        healthKitManager.requestAuthorization { [weak self] success, _ in
            if success {
                self?.healthKitManager.startObservingWeightChanges()
                NotificationCenter.default.addObserver(self!,
                                                       selector: #selector(self?.handleHealthKitDataChange),
                                                       name: .healthKitWeightDataChanged,
                                                       object: nil)
                self?.importHistoricalWeightsFromHealthKit()
                self?.updateWeightFromHealthKit()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .healthKitWeightDataChanged, object: nil)
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
                }
            } else {
                // Create a new profile with default values.
                let newProfile = UserProfile(context: context)
                newProfile.name = ""
                newProfile.gender = "Male"
                newProfile.age = 25
                newProfile.height = 170
                newProfile.dailyCalorieGoal = 1500
                newProfile.startWeight = 70.0
                newProfile.currentWeight = 70.0
                newProfile.goalWeight = 65.0
                newProfile.profileImageData = nil
                try context.save()
                DispatchQueue.main.async {
                    self.profile = newProfile
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
                self.weightHistoryManager.saveDailyWeight(currentWeight: newWeight)
            }
        }
    }
    
    // Update weight only if the difference is greater than 0.5 kg.
    func updateWeightFromHealthKit() {
        healthKitManager.fetchLatestWeight { [weak self] fetchedWeight in
            guard let self = self, let newWeight = fetchedWeight else { return }
            DispatchQueue.main.async {
                if let currentWeight = self.profile?.currentWeight, abs(newWeight - currentWeight) > 0.5 {
                    self.updateCurrentWeight(newWeight)
                }
            }
        }
    }
    
    func importHistoricalWeightsFromHealthKit() {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        healthKitManager.fetchHistoricalDailyWeights(startDate: oneYearAgo, endDate: Date()) { [weak self] dailyWeights in
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
    
    var dailyCalorieGoal: Int {
        get { Int(profile?.dailyCalorieGoal ?? 1500) }
        set {
            profile?.dailyCalorieGoal = Int32(newValue)
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
