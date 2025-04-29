
import SwiftUI
import CoreData

// MARK: - Additional Views

/// A detailed day view card that displays information for a selected day.
/// The card shows the full date along with nutritional and activity data,
/// and it features an animated appearance with scaling and blur effects.
struct DayDetailCardView: View {
    // MARK: - Explicit Initializer
    init(date: Date,
         userProfileViewModel: UserProfileViewModel,
         burnedCaloriesViewModel: BurnedCaloriesViewModel,
         waterViewModel: WaterViewModel,
         context: NSManagedObjectContext) {
        self.date = date
        self.userProfileViewModel = userProfileViewModel
        self.burnedCaloriesViewModel = burnedCaloriesViewModel
        self.waterViewModel = waterViewModel
        _dateFoodViewModel = StateObject(wrappedValue: DateFoodViewModel(date: date, context: context))
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
    private var consumedCaloriesValue: Double {
        Double(dateFoodViewModel.totalCalories)
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
            // Display the full date in a bold, medium-sized font.
            Text(formattedFullDate(date))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding(.top, 8)
                .opacity(showContent ? 1 : 0)
            
            // A divider to separate the date header from the details.
            Divider()
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .opacity(showContent ? 1 : 0)
            
            // Info rows displaying nutritional and activity data.
            VStack(spacing: 12) {
                InfoRow(title: "Goal:", value: "\(userProfileViewModel.dailyCalorieGoal) kcal")
                InfoRow(title: "Consumed:", value: "\(Int(consumedCaloriesValue)) kcal")
                InfoRow(title: "Burned:", value: "\(Int(burnedCaloriesValue)) kcal")
                InfoRow(title: "Net:", value: "\(Int(netCaloriesValue)) kcal")
                InfoRow(title: "Remaining:", value: "\(Int(remainingCaloriesValue)) kcal")
                InfoRow(title: "Water:", value: waterText)
            }
            .opacity(showContent ? 1 : 0)
            .padding(.horizontal)

            // Food sections for this day
            DateFoodSectionsView(date: date, context: context)
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showContent)
                .padding(.top, 8)
        }
        .padding()
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
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .font(.system(size: 20, weight: .medium))
            Spacer()
            Text(value)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .font(.system(size: 20, weight: .medium))
        }
    }
}
