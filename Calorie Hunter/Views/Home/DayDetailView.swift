/*import SwiftUI
import CoreData
import HealthKit
import Combine

struct DayDetailCardView: View {
    private static var hasAnimatedBurnedCalories = false

    let date: Date
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var goalsViewModel: GoalsViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    @ObservedObject var waterViewModel: WaterViewModel
    @ObservedObject var stepsViewModel: StepsViewModel
    let context: NSManagedObjectContext
    let onBack: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    @State private var animatedCalories: Double = 0
    @StateObject private var dateFoodViewModel: DateFoodViewModel

    // Cached goals for the selected day (avoid Core Data fetches in body)
    @State private var goalCalories: Double = 0
    @State private var goalBurned:   Double = 0
    @State private var goalSteps:    Double = 0
    @State private var goalWater:    Double = 0

    init(date: Date,
         userProfileViewModel: UserProfileViewModel,
         goalsViewModel: GoalsViewModel,
         burnedCaloriesViewModel: BurnedCaloriesViewModel,
         waterViewModel: WaterViewModel,
         stepsViewModel: StepsViewModel,
         context: NSManagedObjectContext,
         onBack: @escaping () -> Void) {
        self.date = date
        self.userProfileViewModel = userProfileViewModel
        self.goalsViewModel = goalsViewModel
        self.burnedCaloriesViewModel = burnedCaloriesViewModel
        self.waterViewModel = waterViewModel
        self.stepsViewModel = stepsViewModel
        self.context = context
        _dateFoodViewModel = StateObject(wrappedValue: DateFoodViewModel(date: date, context: context))
        self.onBack = onBack
    }

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    // Load goals for a specific day. Today reads from GoalsViewModel; past days from GoalsManager.
    @MainActor
    private func loadGoalsForDay(_ d: Date) async {
        if Calendar.current.isDateInToday(d) {
            goalCalories = Double(goalsViewModel.dailyCalorieGoal)
            goalBurned   = Double(goalsViewModel.dailyBurnedCaloriesGoal)
            goalSteps    = Double(goalsViewModel.dailyStepsGoal)
            goalWater    = goalsViewModel.dailyWaterGoal
        } else {
            goalCalories = GoalsManager.shared.goalValue(for: .calories,       on: d)
            goalBurned   = GoalsManager.shared.goalValue(for: .burnedCalories, on: d)
            goalSteps    = GoalsManager.shared.goalValue(for: .steps,          on: d)
            goalWater    = GoalsManager.shared.goalValue(for: .water,          on: d)
        }
    }

    private func goalValue(for type: GoalType, on date: Date) -> Double {
        if Calendar.current.isDateInToday(date) {
            switch type {
            case .calories:       return Double(goalsViewModel.dailyCalorieGoal)
            case .burnedCalories: return Double(goalsViewModel.dailyBurnedCaloriesGoal)
            case .steps:          return Double(goalsViewModel.dailyStepsGoal)
            case .water:          return goalsViewModel.dailyWaterGoal
            default:               return GoalsManager.shared.goalValue(for: type, on: date)
            }
        } else {
            return GoalsManager.shared.goalValue(for: type, on: date)
        }
    }

    // MARK: – Computed
    private var consumedCalories: Double {
        Double(dateFoodViewModel.totalCalories)
    }
    private var burnedCalories: Double {
        if let hist = BurnedCaloriesHistoryManager.shared
            .burnedCaloriesForPeriod(days: 30)
            .first(where: { $0.date == Self.isoFormatter.string(from: date) })?
            .burnedCalories {
            return hist
        } else if Calendar.current.isDateInToday(date) {
            return burnedCaloriesViewModel.currentBurnedCalories
        } else { return 0 }
    }
    private var netCalories: Double {
        consumedCalories - burnedCalories
    }
    private var remainingCalories: Double {
        goalCalories - netCalories
    }
    private var fullDateText: String {
        Self.displayFormatter.string(from: date)
    }

    var body: some View {
        ScrollView {
            // Top bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                      .font(.title2)
                      .foregroundColor(.primary)
                }
                Spacer()
                Text(fullDateText)
                  .font(.system(size: 20, weight: .bold))
                  .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Cards grid
            
            VStack( spacing: 25) {
                
                DateFoodSectionsView(date: date, context: context)
                
                    MetricCardView(
                        iconName: "fork.knife",
                        title: "Consumed",
                        valueText: "\(Int(consumedCalories)) kcal",
                        current: consumedCalories,
                        goal: goalCalories,
                        gradientColors: [Color.orange, Color.red]
                    )
                    MetricCardView(
                        iconName: "flame.fill",
                        title: "Burned",
                        valueText: "\(Int(burnedCalories)) kcal",
                        current: burnedCalories,
                        goal: goalBurned,
                        gradientColors: [Color.pink, Color.orange]
                    )
                
                    MetricCardView(
                        iconName: "figure.walk",
                        title: "Steps",
                        valueText: "\(stepsViewModel.steps(for: date))",
                        current: Double(stepsViewModel.steps(for: date)),
                        goal: goalSteps,
                        gradientColors: [Color.cyan, Color.green]
                    )
                 
                    MetricCardView(
                        iconName: "drop.fill",
                        title: "Water",
                        valueText: String(format: "%.1f L", waterViewModel.waterAmount(for: date)),
                        current: waterViewModel.waterAmount(for: date),
                        goal: goalWater,
                        gradientColors: [Color.blue, Color.cyan]
                    )
                }
                .padding()
            
            
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        .task(id: Calendar.current.startOfDay(for: date)) {
            await loadGoalsForDay(date)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            Task { await loadGoalsForDay(Date()) }
        }
    }
}

struct DayDetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController.shared.container.viewContext
        DayDetailCardView(
            date: Date(),
            userProfileViewModel: UserProfileViewModel(),
            goalsViewModel: GoalsViewModel(),
            burnedCaloriesViewModel: BurnedCaloriesViewModel(),
            waterViewModel: WaterViewModel(container: PersistenceController.shared.container),
            stepsViewModel: StepsViewModel(),
            context: ctx,
            onBack: {}
        )
        .environment(\.managedObjectContext, ctx)
    }
}
*/
