import SwiftUI
import CoreData
import Combine

final class GoalsViewModel: ObservableObject {
    // MARK: - Core Data
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var profile: UserProfile?

    private var saveWorkItem: DispatchWorkItem?
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.saveProfile() }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }

    // MARK: -- Calories Goal
    @Published var dailyCalorieGoalValue: Int = 1500
    var dailyCalorieGoal: Int {
        get { dailyCalorieGoalValue }
        set {
            objectWillChange.send()
            dailyCalorieGoalValue = newValue
            profile?.dailyCalorieGoal = Int32(newValue)
            scheduleSave()
        }
    }
    
    // MARK: -- Protein Goal
    @Published var dailyProteinGoalValue: Int = 160
    var dailyProteinGoal: Int {
        get { dailyProteinGoalValue }
        set {
            objectWillChange.send()
            dailyProteinGoalValue = newValue
            profile?.dailyProteinGoal = Int32(newValue)
            scheduleSave()
        }
    }

    // MARK: -- Steps Goal
    @Published var dailyStepsGoalValue: Int = 10000
    var dailyStepsGoal: Int {
        get { dailyStepsGoalValue }
        set {
            objectWillChange.send()
            dailyStepsGoalValue = newValue
            profile?.dailyStepsGoal = Int32(newValue)
            scheduleSave()
        }
    }

    // MARK: -- Burned Calories Goal
    @Published var dailyBurnedCaloriesGoalValue: Int = 500
    var dailyBurnedCaloriesGoal: Int {
        get { dailyBurnedCaloriesGoalValue }
        set {
            objectWillChange.send()
            dailyBurnedCaloriesGoalValue = newValue
            profile?.dailyBurnedCaloriesGoal = Int32(newValue)
            scheduleSave()
        }
    }

    // MARK: -- Water Goal
    @Published var dailyWaterGoalValue: Double = 2.0
    var dailyWaterGoal: Double {
        get { dailyWaterGoalValue }
        set {
            objectWillChange.send()
            dailyWaterGoalValue = newValue
            profile?.dailyWaterGoal = newValue
            scheduleSave()
        }
    }

    // MARK: -- Weekly Weight Change Goal (kg/week)
    @Published var weeklyWeightChangeGoalValue: Double = 0.0
    var weeklyWeightChangeGoal: Double {
        get { weeklyWeightChangeGoalValue }
        set {
            objectWillChange.send()
            weeklyWeightChangeGoalValue = newValue
            profile?.weeklyWeightChangeGoal = newValue
            scheduleSave()
        }
    }

    // MARK: -- Goal Weight (target body weight)
    @Published var goalWeightValue: Double = 65.0
    var goalWeight: Double {
        get { goalWeightValue }
        set {
            objectWillChange.send()
            goalWeightValue = newValue
            profile?.goalWeight = newValue
            scheduleSave()
        }
    }

    // MARK: - Optional: Goals history integration (unchanged semantics)
    private let goalsManager = GoalsManager.shared

    // MARK: - Init
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfile()

        // Observe Core Data changes to keep published properties in sync
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextObjectsDidChange(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Load/Save
    private func loadProfile() {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            if let existing = profiles.first {
                self.profile = existing
                // Initialize goal values from persisted profile
                dailyCalorieGoalValue        = Int(existing.dailyCalorieGoal)
                dailyProteinGoalValue        = Int(existing.dailyProteinGoal)
                dailyStepsGoalValue          = Int(existing.dailyStepsGoal)
                dailyBurnedCaloriesGoalValue = Int(existing.dailyBurnedCaloriesGoal)
                dailyWaterGoalValue          = existing.dailyWaterGoal
                weeklyWeightChangeGoalValue  = existing.weeklyWeightChangeGoal
                goalWeightValue              = existing.goalWeight

                goalsManager.updateGoal(Double(existing.dailyCalorieGoal),        for: GoalType.calories,       on: Date())
                goalsManager.updateGoal(Double(existing.dailyProteinGoal),        for: GoalType.calories,       on: Date())
                goalsManager.updateGoal(Double(existing.dailyStepsGoal),          for: GoalType.steps,          on: Date())
                goalsManager.updateGoal(Double(existing.dailyBurnedCaloriesGoal), for: GoalType.burnedCalories, on: Date())
            } else {
                self.profile = nil
            }
        } catch {
            print("GoalsViewModel: Error loading profile: \(error)")
        }
    }

    private func saveProfile() {
        guard context.hasChanges else { return }
        do { try context.save() } catch {
            print("GoalsViewModel: Error saving profile: \(error)")
        }
    }

    // MARK: - Core Data sync -> Published properties
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        guard let profile = profile else { return }

        let newCal = Int(profile.dailyCalorieGoal)
        if newCal != dailyCalorieGoalValue {
            DispatchQueue.main.async { self.dailyCalorieGoalValue = newCal }
        }
        
        let newPro = Int(profile.dailyProteinGoal)
        if newCal != dailyProteinGoalValue {
            DispatchQueue.main.async { self.dailyProteinGoalValue = newPro }
        }

        let newSteps = Int(profile.dailyStepsGoal)
        if newSteps != dailyStepsGoalValue {
            DispatchQueue.main.async { self.dailyStepsGoalValue = newSteps }
        }

        let newBurned = Int(profile.dailyBurnedCaloriesGoal)
        if newBurned != dailyBurnedCaloriesGoalValue {
            DispatchQueue.main.async { self.dailyBurnedCaloriesGoalValue = newBurned }
        }

        let newWater = profile.dailyWaterGoal
        if newWater != dailyWaterGoalValue {
            DispatchQueue.main.async { self.dailyWaterGoalValue = newWater }
        }

        let newWeekly = profile.weeklyWeightChangeGoal
        if newWeekly != weeklyWeightChangeGoalValue {
            DispatchQueue.main.async { self.weeklyWeightChangeGoalValue = newWeekly }
        }

        let newGoalWeight = profile.goalWeight
        if newGoalWeight != goalWeightValue {
            DispatchQueue.main.async { self.goalWeightValue = newGoalWeight }
        }
    }
}
