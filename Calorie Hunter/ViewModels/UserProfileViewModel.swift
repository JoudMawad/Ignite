import SwiftUI

class UserProfileViewModel: ObservableObject {
    @AppStorage("userProfile") private var userData: Data?
    
    @Published var name: String = ""
    @Published var gender: String = ""
    @Published var age: Int = 25
    @Published var height: Int = 170
    @Published var dailyCalorieGoal: Int = 1500
    @Published var startWeight: Double = 70.0
    @Published var currentWeight: Double = 70.0
    @Published var goalWeight: Double = 65.0

    private let weightHistoryManager = WeightHistoryManager.shared
    private let healthKitManager = HealthKitManager.shared
    private var reimportWorkItem: DispatchWorkItem?
    
    init() {
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
        if let savedData = userData,
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            DispatchQueue.main.async {
                self.name = decodedProfile.name
                self.gender = decodedProfile.Gender
                self.age = decodedProfile.age
                self.height = decodedProfile.height
                self.dailyCalorieGoal = decodedProfile.dailyCalorieGoal
                self.startWeight = decodedProfile.startWeight
                self.currentWeight = decodedProfile.currentWeight
                self.goalWeight = decodedProfile.goalWeight
            }
        }
    }
    
    func saveProfile() {
        let profile = UserProfile(
            name: self.name,
            Gender: self.gender,
            age: self.age,
            height: self.height,
            dailyCalorieGoal: self.dailyCalorieGoal,
            startWeight: self.startWeight,
            currentWeight: self.currentWeight,
            goalWeight: self.goalWeight,
            profileImageData: nil
        )
        if let encodedData = try? JSONEncoder().encode(profile) {
            userData = encodedData
        }
    }
    
    func updateCurrentWeight(_ newWeight: Double) {
        DispatchQueue.main.async {
            self.currentWeight = newWeight
            self.saveProfile()
            self.weightHistoryManager.saveDailyWeight(currentWeight: newWeight)
        }
    }
    
    // Update only if the difference is greater than 0.5 kg.
    func updateWeightFromHealthKit() {
        healthKitManager.fetchLatestWeight { [weak self] fetchedWeight in
            guard let self = self, let newWeight = fetchedWeight else { return }
            DispatchQueue.main.async {
                if abs(newWeight - self.currentWeight) > 0.5 {
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
}
