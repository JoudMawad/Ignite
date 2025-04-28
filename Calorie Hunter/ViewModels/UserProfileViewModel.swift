//
//  UserPreDefinedFoodsViewModel.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 04.03.25.
//

import SwiftUI
import CoreData

// UserProfileViewModel is responsible for managing the user's profile data,
// including personal details, goals, and weight information.
// It loads and saves profile data from Core Data and listens to HealthKit updates.
class UserProfileViewModel: ObservableObject {
    // Published property for the entire user profile.
    @Published var profile: UserProfile?
    
    // Published properties for various goals and weight values.
    // Using separate properties ensures that UI updates immediately when these values change.
    @Published var dailyCalorieGoalValue: Int = 1500
    @Published var dailyStepsGoalValue: Int = 10000
    @Published var dailyBurnedCaloriesGoalValue: Int = 500
    @Published var startWeightValue: Double = 70.0
    @Published var currentWeightValue: Double = 70.0
    @Published var goalWeightValue: Double = 65.0

    // Managers to handle weight history and HealthKit weight updates.
    private let weightHistoryManager = WeightHistoryManager.shared
    private let weightManager = WeightManager()
    // A DispatchWorkItem to manage delayed re-imports when HealthKit data changes.
    private var reimportWorkItem: DispatchWorkItem?
    
    // The Core Data context for fetching and saving the user profile.
    private var context: NSManagedObjectContext

    /// Initializes the view model with a Core Data context.
    /// It loads the user profile and sets up observers for Core Data changes and HealthKit updates.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfile()
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
    
    /// Loads the user profile from Core Data.
    /// If no profile exists, it creates a new one with default values.
    func loadProfile() {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            if let existingProfile = profiles.first {
                DispatchQueue.main.async {
                    self.profile = existingProfile
                    // goals
                    self.dailyCalorieGoalValue = Int(existingProfile.dailyCalorieGoal)
                    // sync weights into your @Published state
                    self.startWeightValue   = existingProfile.startWeight
                    self.currentWeightValue = existingProfile.currentWeight
                    self.goalWeightValue    = existingProfile.goalWeight
                }
            } else {
                let newProfile = UserProfile(context: context)
                // ... your default assignments ...
                try context.save()
                DispatchQueue.main.async {
                    self.profile = newProfile
                    self.dailyCalorieGoalValue = 1500
                    // initialize the weight values, too
                    self.startWeightValue   = newProfile.startWeight
                    self.currentWeightValue = newProfile.currentWeight
                    self.goalWeightValue    = newProfile.goalWeight
                }
            }
        } catch {
            print("Error loading profile: \(error)")
        }
    }
    
    /// Saves the current user profile to Core Data.
    func saveProfile() {
        do {
            try context.save()
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
            objectWillChange.send()  // Notify SwiftUI of the upcoming change.
            profile?.name = newValue
            saveProfile()
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
            profile?.age = Int32(newValue)
            saveProfile()
        }
    }
    
    /// Returns the user's height, defaulting to 170 if not set.
    var height: Int {
        get { Int(profile?.height ?? 170) }
        set {
            profile?.height = Int32(newValue)
            saveProfile()
        }
    }
    
    /// Returns and sets the user's start weight.
    var startWeight: Double {
        get { startWeightValue }
        set {
            objectWillChange.send()
            startWeightValue = newValue
            profile?.startWeight = newValue
            saveProfile()
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
            saveProfile()
        }
    }
    
    /// Returns and sets the user's daily calorie goal.
    var dailyCalorieGoal: Int {
        get { dailyCalorieGoalValue }
        set {
            objectWillChange.send()  // Force immediate UI update.
            dailyCalorieGoalValue = newValue
            profile?.dailyCalorieGoal = Int32(newValue)
            saveProfile()
        }
    }
    
    /// Returns and sets the user's daily steps goal.
    var dailyStepsGoal: Int {
        get { dailyStepsGoalValue }
        set {
            objectWillChange.send()  // Notify immediately.
            dailyStepsGoalValue = newValue
            profile?.dailyStepsGoal = Int32(newValue)
            saveProfile()
        }
    }
    
    /// Returns and sets the user's daily burned calories goal.
    var dailyBurnedCaloriesGoal: Int {
        get { dailyBurnedCaloriesGoalValue }
        set {
            objectWillChange.send()
            dailyBurnedCaloriesGoalValue = newValue
            profile?.dailyBurnedCaloriesGoal = Int32(newValue)
            saveProfile()
        }
    }
    
    /// Returns and sets the user's gender.
    var gender: String {
        get { profile?.gender ?? "Male" }
        set {
            profile?.gender = newValue
            saveProfile()
        }
    }
}
