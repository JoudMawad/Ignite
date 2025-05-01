//
//  AddExerciseView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 25.04.25.
//


import SwiftUI
import UIKit
import HealthKit

// MARK: - Subviews

/// A reusable search bar for filtering exercises
struct SearchBarView: View {
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search exercise…", text: $text)
                    .padding(.vertical, 10)
                    .padding(.leading, 16)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .padding(.trailing, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: .primary.opacity(0.15), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 23)
        .padding(.top, 25)
    }
}

/// A single activity row, including label, expand/collapse button, and details
struct ActivityRowView: View {
    let activity: HKWorkoutActivityType
    @Binding var selectedActivity: HKWorkoutActivityType?
    @Binding var isDetailsPresented: Bool
    @Binding var duration: String
    @Binding var distance: String
    let distanceBasedActivities: Set<HKWorkoutActivityType>
    let saveAction: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if selectedActivity == activity && isDetailsPresented {
                        isDetailsPresented = false
                    } else {
                        selectedActivity = activity
                        isDetailsPresented = true
                    }
                }
            } label: {
                HStack {
                    Text(activity.displayName)
                        .foregroundColor(.primary)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                    Spacer()
                    Image(systemName: selectedActivity == activity && isDetailsPresented ? "chevron.up" : "plus.circle")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            Divider()
            if selectedActivity == activity && isDetailsPresented {
                ActivityDetailView(
                    activity: activity,
                    duration: $duration,
                    distance: $distance,
                    distanceBasedActivities: distanceBasedActivities,
                    saveAction: saveAction,
                    cancelAction: {
                        withAnimation(.spring()) {
                            isDetailsPresented = false
                        }
                        duration = ""
                        distance = ""
                    }
                )
            }
        }
    }
}

/// The detail form shown when an activity row is expanded
struct ActivityDetailView: View {
    let activity: HKWorkoutActivityType
    @Binding var duration: String
    @Binding var distance: String
    let distanceBasedActivities: Set<HKWorkoutActivityType>
    let saveAction: () -> Void
    let cancelAction: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    /// Haptic feedback for the cancel button in activity detail.
    private let cancelTapFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Duration (min)")
                    .font(.headline)
                Spacer()
                TextField("0", text: $duration)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            if distanceBasedActivities.contains(activity) {
                HStack {
                    Text("Distance (km)")
                        .font(.headline)
                    Spacer()
                    TextField("0", text: $distance)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
            HStack(spacing: 20) {
                Button("Cancel") {
                    cancelTapFeedback.impactOccurred()
                    cancelAction()
                }
                .buttonStyle(.bordered)
                .tint(.primary)

                Button("Save") {
                    saveAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(8)
        .clipped()
    }
}

struct AddExerciseView: View {
    // MARK: - Dependencies
    @ObservedObject var viewModel: ExerciseViewModel
    @EnvironmentObject var userProfile: UserProfileViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    /// Haptic feedback for save/cancel actions.
    private let successFeedback = UINotificationFeedbackGenerator()
    private let errorFeedback   = UINotificationFeedbackGenerator()
    private let tapFeedback     = UIImpactFeedbackGenerator(style: .light)
    /// Haptic feedback for the cancel button in activity detail.
    private let cancelTapFeedback = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Search / View State
    @State private var searchText: String = ""
    @State private var selectedActivity: HKWorkoutActivityType?
    @State private var isDetailsPresented: Bool = false
    @State private var duration: String = ""
    @State private var distance: String = ""

    // MARK: - Usage Counts
    /// Counts how many times each activity was used in the viewModel's history
    private var usageCounts: [String: Int] {
        Dictionary(viewModel.exercises.map { ($0.type, 1) }, uniquingKeysWith: +)
    }

    // MARK: - Activity Pool sorted by usage
    /// Activities, sorted by descending usage frequency then alphabetically
    private var activityPool: [HKWorkoutActivityType] {
        let baseList: [HKWorkoutActivityType] = [
            .americanFootball, .archery, .australianFootball, .badminton,
            .baseball, .basketball, .bowling, .boxing, .climbing, .cricket,
            .curling, .cycling, .cardioDance, .socialDance, .barre,
            .elliptical, .equestrianSports, .fencing, .fishing,
            .functionalStrengthTraining, .golf, .gymnastics, .handball,
            .hiking, .hockey, .hunting, .lacrosse, .martialArts,
            .mindAndBody, .mixedCardio, .paddleSports, .play,
            .preparationAndRecovery, .racquetball, .rowing, .rugby,
            .running, .sailing, .skatingSports, .snowSports, .soccer,
            .softball, .squash, .stairClimbing, .surfingSports, .swimming,
            .tableTennis, .tennis, .trackAndField, .traditionalStrengthTraining,
            .volleyball, .walking, .waterFitness, .waterPolo, .waterSports,
            .wrestling, .yoga
        ]
        return baseList.sorted { a, b in
            let countA = usageCounts[a.displayName] ?? 0
            let countB = usageCounts[b.displayName] ?? 0
            if countA != countB {
                return countA > countB
            } else {
                return a.displayName < b.displayName
            }
        }
    }

    // MARK: - Distance-based Activities
    private let distanceBasedActivities: Set<HKWorkoutActivityType> = [
        .running, .walking, .cycling
    ]

    // Filtered list based on search text
    private var filteredActivities: [HKWorkoutActivityType] {
        if searchText.isEmpty { return activityPool }
        return activityPool.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title
                Text("Add Exercise")
                    .font(.system(size: 33, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 23)
                    .padding(.top, 30)

                // Search Bar
                SearchBarView(text: $searchText)

                // Activity List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredActivities, id: \.self) { activity in
                            ActivityRowView(
                                activity: activity,
                                selectedActivity: $selectedActivity,
                                isDetailsPresented: $isDetailsPresented,
                                duration: $duration,
                                distance: $distance,
                                distanceBasedActivities: distanceBasedActivities,
                                saveAction: { saveExercise(activity) }
                            )
                        }
                    }
                    .padding(.horizontal, 23)
                    .padding(.top, 13)
                }

                Spacer()

                // Done button
                Button("Done") {
                    tapFeedback.impactOccurred()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding(.bottom, 20)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Helpers
    private func saveExercise(_ activity: HKWorkoutActivityType) {
        // Validate duration
        guard let dur = Double(duration), dur > 0 else {
            errorFeedback.notificationOccurred(.error)
            return
        }
        // Compute distance in meters if applicable
        let distanceMeters: Double? = {
            if let distKm = Double(distance), distanceBasedActivities.contains(activity) {
                return distKm * 1000
            }
            return nil
        }()
        // Perform save
        viewModel.addExercise(
            type: activity,
            startDate: Date(),
            duration: dur * 60,
            distance: distanceMeters,
            userProfile: userProfile
        )
        // Success haptic and dismiss
        successFeedback.notificationOccurred(.success)
        dismiss()
    }
}

#if DEBUG
struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView(viewModel: ExerciseViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
#endif
