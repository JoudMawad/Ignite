import SwiftUI
import CoreData

// MARK: - Additional Views

/// A detailed day view card that displays information for a selected day.
/// The card shows the full date along with nutritional and activity data,
/// and it features an animated appearance with scaling and blur effects.
struct DayDetailCardView: View {
    /// Callback for going back to the calendar
    let onBack: () -> Void

    // MARK: - Explicit Initializer
    init(date: Date,
         userProfileViewModel: UserProfileViewModel,
         burnedCaloriesViewModel: BurnedCaloriesViewModel,
         waterViewModel: WaterViewModel,
         context: NSManagedObjectContext,
         onBack: @escaping () -> Void) {
        self.date = date
        self.userProfileViewModel = userProfileViewModel
        self.burnedCaloriesViewModel = burnedCaloriesViewModel
        self.waterViewModel = waterViewModel
        _dateFoodViewModel = StateObject(wrappedValue: DateFoodViewModel(date: date, context: context))
        self.onBack = onBack
    }
    // MARK: - Static Properties
    
    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    // MARK: - Input Properties
    
    /// The specific date for which to display detailed information.
    let date: Date
    
    /// The view model providing user profile information.
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    
    /// The view model that tracks burned calories.
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    
    /// The view model that tracks water intake.
    @ObservedObject var waterViewModel: WaterViewModel
    

    // MARK: - Environment
    
    /// Access the current color scheme to adjust styling dynamically.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    @State private var showContent: Bool = false
    @StateObject private var dateFoodViewModel: DateFoodViewModel

    // MARK: - Computed Properties
    
    /// Formats the given date as a string ("yyyy-MM-dd") for history lookups.
    private var formattedDateString: String {
        Self.isoFormatter.string(from: date)
    }
    
    /// Retrieves the burned calories for the given date from history.
    private var burnedCaloriesForDate: Double? {
        // Retrieve a 30-day period of burned calories history.
        let history = BurnedCaloriesHistoryManager.shared.burnedCaloriesForPeriod(days: 30)
        // Match the formatted date string.
        return history.first(where: { $0.date == formattedDateString })?.burnedCalories
    }
    
    /// Returns a displayable string for burned calories, based on available data.
    private var burnedCaloriesText: String {
        if let burned = burnedCaloriesForDate {
            return "\(Int(burned)) kcal"
        } else if Calendar.current.isDateInToday(date) {
            // If today's data isn't in history, use the current value from the view model.
            return "\(Int(burnedCaloriesViewModel.currentBurnedCalories)) kcal"
        } else {
            return "Data unavailable"
        }
    }
    
    /// Returns a formatted string for the water consumption on the given date.
    private var waterText: String {
        let waterAmount = waterViewModel.waterAmount(for: date)
        return String(format: "%.1f L", waterAmount)
    }
    
    // caloriesText is now replaced by values from dateFoodViewModel.

    // MARK: - Net Calorie Calculations
    /// Numeric calories consumed on this date.
    ///
    /// userProfileViewModel.dailyCalorieGoal + burnedCaloriesValue
    private var consumedCaloriesValue: Double {
        Double(dateFoodViewModel.totalCalories)
    }
    private var goalCaloriesValue: Double {
        Double(burnedCaloriesValue) + Double(userProfileViewModel.dailyCalorieGoal)
    }
    /// Numeric burned calories for this date.
    private var burnedCaloriesValue: Double {
        if let historyValue = burnedCaloriesForDate {
            return historyValue
        } else if Calendar.current.isDateInToday(date) {
            return burnedCaloriesViewModel.currentBurnedCalories
        } else {
            return 0.0
        }
    }
    /// Net calories = consumed − burned.
    private var netCaloriesValue: Double {
        consumedCaloriesValue - burnedCaloriesValue
    }
    /// Remaining calories = goal − net.
    private var remainingCaloriesValue: Double {
        Double(userProfileViewModel.dailyCalorieGoal) - netCaloriesValue
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Spacer()
                    Text(formattedFullDate(date))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .opacity(showContent ? 1 : 0)
                    Spacer()
                }
                Spacer()
            }
            .padding(.bottom, 4)
            .padding(.horizontal)
            .padding(.top, 8)

            
            
            // A divider to separate the date header from the details.
            Divider()
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .opacity(showContent ? 1 : 0)
            
            // Info rows displaying nutritional and activity data.
            VStack(spacing: 12) {
                    InfoRow(title: "Your Goal was:", value: "\(Int(goalCaloriesValue)) kcal")
                    InfoRow(title: "You have Consumed:", value: "\(Int(consumedCaloriesValue)) kcal")
                
                    InfoRow(title: "Youe have Burned:", value: "\(Int(burnedCaloriesValue)) kcal")
                
                InfoRow(title: "Your Net Calorie Intake:", value: "\(Int(netCaloriesValue)) kcal")
                InfoRow(title: "You Drank:", value: waterText)
            }
            .opacity(showContent ? 1 : 0)
            .padding(.horizontal)

            // Food sections for this day
            DateFoodSectionsView(date: date, context: context)
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showContent)
                .padding(.top, 8)
        }
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.4), value: showContent)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }
    
    // MARK: - Helper Methods
    
    /// Formats the date to a medium style string for display.
    /// - Parameter date: The date to format.
    /// - Returns: A string representing the date.
    private func formattedFullDate(_ date: Date) -> String {
        Self.displayFormatter.string(from: date)
    }
}

/// A subview representing a single information row with a title and value.
struct InfoRow: View {
    var title: String
    var value: String

    /// Adjusts the text color based on the current color scheme.
    @Environment(\.colorScheme) var colorScheme

    private var iconName: String {
        let lower = title.lowercased()
        if lower.contains("goal") { return "target" }
        else if lower.contains("consumed") { return "fork.knife" }
        else if lower.contains("burned") { return "flame.fill" }
        else if lower.contains("net") { return "chart.bar.fill" }
        else if lower.contains("drank") { return "drop.fill" }
        else { return "info.circle" }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text(title)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .font(.system(size: 18, weight: .medium))
            Spacer()
            Text(value)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .font(.system(size: 18, weight: .medium))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

// MARK: - Previews
struct DayDetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory Core Data context for previews
        let context = PersistenceController.shared.container.viewContext
        DayDetailCardView(
            date: Date(),
            userProfileViewModel: UserProfileViewModel(),
            burnedCaloriesViewModel: BurnedCaloriesViewModel(),
            waterViewModel: WaterViewModel(container: PersistenceController.shared.container),
            context: context,
            onBack: {}
        )
        .environment(\.managedObjectContext, context)
    }
}
