import SwiftUI
import HealthKit

struct ExerciseCardView: View {
    @ObservedObject var viewModel: ExerciseViewModel

    @Environment(\.colorScheme) var colorScheme

    @State private var showAddSheet = false
    @State private var isEditing = false

    /// Exercises occurring today.
    private var todayExercises: [Exercise] {
        viewModel.exercises.filter { Calendar.current.isDateInToday($0.startDate) }
    }

    /// Today's total exercise calories.
    private var todayCalories: Double {
        viewModel.exercises
            .filter { Calendar.current.isDateInToday($0.startDate) }
            .map(\.calories)
            .reduce(0, +)
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .top, spacing: 4) {
            Image(systemName: "dumbbell")
                .font(.system(size: 20, weight: .bold))
            Text("Exercise")
                .font(.system(size: 15, weight: .bold))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            Spacer()
            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus.circle")
                    .font(.title2)
            }
            Button(action: { isEditing.toggle() }) {
                Image(systemName: isEditing ? "checkmark.circle" : "pencil.circle")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .foregroundColor(colorScheme == .dark ? .black : .white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Always-visible list of today's exercises.
    private var listView: some View {
        Group {
            if todayExercises.isEmpty {
                Text("No exercises today")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(todayExercises) { ex in
                        HStack {
                            if isEditing {
                                Button(action: { viewModel.deleteExercise(ex) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            Text(ex.type)
                            Spacer()
                            Text(formatDuration(ex.duration))
                            Text("\(Int(ex.calories)) kcal")
                        }
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    }
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            listView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
        .sheet(isPresented: $showAddSheet) {
            AddExerciseView(viewModel: viewModel)
        }
    }
}

// MARK: - Helpers
private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%dm %ds", minutes, seconds)
}

#if DEBUG
struct ExerciseCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy view model for preview purposes
        let vm = ExerciseViewModel()
        ExerciseCardView(viewModel: vm)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
