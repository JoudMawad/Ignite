//
//  AddExerciseView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 25.04.25.
import SwiftUI
import HealthKit

struct AddExerciseView: View {
    // MARK: - Dependencies
    @ObservedObject var viewModel: ExerciseViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss)     private var dismiss

    // MARK: - Search / View State
    @State private var searchText: String = ""
    @State private var selectedActivity: HKWorkoutActivityType?
    @State private var isDetailsPresented: Bool = false
    @State private var duration: String = ""
    @State private var calories: String = ""

    // MARK: - Activity Pool
    private let activityPool: [HKWorkoutActivityType] = [
        .running, .walking, .cycling, .swimming, .yoga,
        .elliptical, .rowing, .hiking, .functionalStrengthTraining
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

                // Search Bar Card
                VStack(spacing: 0) {
                    HStack {
                        TextField("Search exercise…", text: $searchText)
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
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDetailsPresented)

                // Activity List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredActivities, id: \.self) { activity in
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
                                        HStack {
                                            Text("Calories (kcal)")
                                                .font(.headline)
                                            Spacer()
                                            TextField("0", text: $calories)
                                                .keyboardType(.decimalPad)
                                                .multilineTextAlignment(.trailing)
                                                .frame(width: 80)
                                        }
                                        HStack(spacing: 20) {
                                            Button("Cancel") {
                                                withAnimation(.spring()) { isDetailsPresented = false }
                                                duration = ""
                                                calories = ""
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(.primary)

                                            Button("Save") { saveExercise(activity) }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.primary)
                                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                        }
                                    }
                                    .padding()
                                    .background(colorScheme == .dark ? Color.black : Color.white)
                                    .cornerRadius(8)
                                    .frame(maxHeight: isDetailsPresented ? nil : 0)
                                    .opacity(isDetailsPresented ? 1 : 0)
                                    .clipped()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 23)
                    .padding(.top, 13)
                }

                Spacer()

                // Done button
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.bottom, 20)
            }
            .background(colorScheme == .dark ? Color.black : .white)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Helpers
    private func saveExercise(_ activity: HKWorkoutActivityType) {
        guard let dur = Double(duration),
              let cal = Double(calories),
              dur > 0 else { return }
        viewModel.addExercise(type: activity,
                              startDate: Date(),
                              duration: dur * 60,  // minutes -> seconds
                              calories: cal)
        dismiss()
    }
}

// MARK: - Display Name helper
private extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .running:   return "Running"
        case .walking:   return "Walking"
        case .cycling:   return "Cycling"
        case .swimming:  return "Swimming"
        case .yoga:      return "Yoga"
        case .elliptical:return "Elliptical"
        case .rowing:    return "Rowing"
        case .hiking:    return "Hiking"
        case .functionalStrengthTraining: return "Strength Training"
        default:         return String(describing: self).capitalized
        }
    }
}

#if DEBUG
struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView(viewModel: ExerciseViewModel())
    }
}
#endif
