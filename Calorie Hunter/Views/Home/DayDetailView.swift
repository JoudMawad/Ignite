import SwiftUI

/// A detailed day view card that displays information for a selected day.
/// The card shows the full date along with nutritional and activity data,
/// and it features an animated appearance with scaling and blur effects.
struct DayDetailCardView: View {
    // MARK: - Input Properties
    
    /// The specific date for which to display detailed information.
    let date: Date
    
    /// The view model providing user profile information.
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    
    /// The view model that tracks burned calories.
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    
    /// The view model that tracks water intake.
    @ObservedObject var waterViewModel: WaterViewModel
    
    /// The view model that manages food-related data.
    @ObservedObject var foodViewModel: FoodViewModel

    // MARK: - Environment
    
    /// Access the current color scheme to adjust styling dynamically.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Animation State
    
    /// Starting scale for the card animation.
    @State private var cardScale: CGFloat = 0.3
    
    /// Starting blur for the card animation.
    @State private var cardBlur: CGFloat = 10.0

    // MARK: - Computed Properties
    
    /// Formats the given date as a string ("yyyy-MM-dd") for history lookups.
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
    
    /// Returns a formatted string for the total calories consumed on the given date.
    private var caloriesText: String {
        return "\(foodViewModel.totalCaloriesForDate(date)) kcal"
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Display the full date in a bold, medium-sized font.
            Text(formattedFullDate(date))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, -8)
            
            // A divider to separate the date header from the details.
            Divider()
                .background(.primary)
            
            // Info rows displaying nutritional and activity data.
            VStack(spacing: 12) {
                InfoRow(title: "Calories:", value: caloriesText)
                InfoRow(title: "Burned Calories:", value: burnedCaloriesText)
                InfoRow(title: "Water:", value: waterText)
            }
            .padding(.horizontal)
        }
        .padding(20)
        .background(
            // Card background with rounded corners and a soft shadow.
            RoundedRectangle(cornerRadius: 55, style: .continuous)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 45)
        // Apply scale and blur effects for the card's expanding animation.
        .scaleEffect(cardScale)
        .blur(radius: cardBlur)
        .onAppear {
            // Animate the card to full scale and remove blur when it appears.
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                cardScale = 1.0
                cardBlur = 0.0
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Formats the date to a medium style string for display.
    /// - Parameter date: The date to format.
    /// - Returns: A string representing the date.
    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
                .foregroundColor(.primary)
                .font(.system(size: 20, weight: .medium))
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .font(.system(size: 20, weight: .medium))
        }
    }
}

struct DayDetailCardView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = UserProfileViewModel()
        let burnedCaloriesVM = BurnedCaloriesViewModel()
        let waterVM = WaterViewModel(container: PersistenceController.shared.container)
        let foodVM = FoodViewModel()
        
        NavigationView {
            DayDetailCardView(
                date: Date(),
                userProfileViewModel: profileVM,
                burnedCaloriesViewModel: burnedCaloriesVM,
                waterViewModel: waterVM,
                foodViewModel: foodVM
            )
        }
    }
}
