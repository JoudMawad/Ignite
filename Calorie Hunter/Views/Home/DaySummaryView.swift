import SwiftUI
import CoreData
import UIKit

struct DaySummaryView: View {
    let date: Date
    @ObservedObject var userProfileVM: UserProfileViewModel
    @ObservedObject var burnedCaloriesVM: BurnedCaloriesViewModel
    @ObservedObject var waterVM: WaterViewModel
    @ObservedObject var stepsVM: StepsViewModel
    @Environment(\.colorScheme) var colorScheme
    let context: NSManagedObjectContext
    /// Called to close the summary view and return to the calendar
    let onClose: () -> Void
    /// Called to present the full day detail view
    let onFullOverview: () -> Void

    private let goalsManager = GoalsManager.shared
    /// Haptic feedback generator for chevron tap.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button {
                    tapFeedback.impactOccurred()
                    onClose()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
                Spacer()
                Text(DateFormatter.localizedString(
                    from: date, dateStyle: .medium, timeStyle: .none))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                Spacer()
            }
            .padding()

            // Two rows of cards
            HStack(spacing: 12) {
                MetricCardView(
                    iconName: "fork.knife",
                    title: "Consumed",
                    valueText: "\(Int(consumedCalories)) kcal",
                    current: consumedCalories,
                    goal: goalsManager.goalValue(for: .calories, on: date),
                    gradientColors: [.blue, .purple]
                )
                MetricCardView(
                    iconName: "flame.fill",
                    title: "Burned",
                    valueText: "\(Int(burnedCalories)) kcal",
                    current: burnedCalories,
                    goal: goalsManager.goalValue(for: .burnedCalories, on: date),
                    gradientColors: [.pink, .orange]
                )
            }
            HStack(spacing: 12) {
                MetricCardView(
                    iconName: "figure.walk",
                    title: "Steps",
                    valueText: "\(stepsVM.steps(for: date))",
                    current: Double(stepsVM.steps(for: date)),
                    goal: goalsManager.goalValue(for: .steps, on: date),
                    gradientColors: [.cyan, .green]
                )
                MetricCardView(
                    iconName: "drop.fill",
                    title: "Water",
                    valueText: String(format: "%.1f L", waterVM.waterAmount(for: date)),
                    current: waterVM.waterAmount(for: date),
                    goal: goalsManager.goalValue(for: .water, on: date),
                    gradientColors: [.blue, .cyan]
                )
            }

            // See full overview
            Button("See Full Overview") {
                tapFeedback.impactOccurred()
                onFullOverview()
            }
            .buttonStyle(.borderedProminent)
            .tint(colorScheme == .dark ? .black : .white)
            .foregroundColor(.primary)
            .font(.system(size: 12, weight: .semibold, design: .rounded))

            Spacer()
        }
    }

    private var consumedCalories: Double {
        Double(DateFoodViewModel(date: date, context: context).totalCalories)
    }
    private var burnedCalories: Double {
        // same helper you had before
        let f = DateFormatter.isoDate.string(from: date)
        let history = BurnedCaloriesHistoryManager.shared.burnedCaloriesForPeriod(days: 30)
        if let e = history.first(where: { $0.date == f }) { return e.burnedCalories }
        else if Calendar.current.isDateInToday(date) { return burnedCaloriesVM.currentBurnedCalories }
        else { return 0 }
    }
}
