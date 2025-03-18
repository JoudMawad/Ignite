import SwiftUI

struct DayDetailCardView: View {
    let date: Date
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    @ObservedObject var waterViewModel: WaterViewModel
    @ObservedObject var foodViewModel: FoodViewModel

    @Environment(\.colorScheme) var colorScheme
    // Starting with a smaller scale and extra blur to simulate motion.
    @State private var cardScale: CGFloat = 0.3
    @State private var cardBlur: CGFloat = 10.0

    // Formatted string ("yyyy-MM-dd") for history lookups.
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Retrieve burned calories from history or current view model.
    private var burnedCaloriesForDate: Double? {
        let history = BurnedCaloriesHistoryManager.shared.burnedCaloriesForPeriod(days: 30)
        return history.first(where: { $0.date == formattedDateString })?.burnedCalories
    }
    
    // Computed properties for display.
    private var burnedCaloriesText: String {
        if let burned = burnedCaloriesForDate {
            return "\(Int(burned)) kcal"
        } else if Calendar.current.isDateInToday(date) {
            return "\(Int(burnedCaloriesViewModel.currentBurnedCalories)) kcal"
        } else {
            return "Data unavailable"
        }
    }
    
    private var waterText: String {
        let waterAmount = waterViewModel.waterAmount(for: date)
        return String(format: "%.1f L", waterAmount)
    }
    
    private var caloriesText: String {
        return "\(foodViewModel.totalCaloriesForDate(date)) kcal"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(formattedFullDate(date))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding(.top, -8)
            
            Divider()
                .background(colorScheme == .dark ? Color.black : Color.white)
            
            VStack(spacing: 12) {
                InfoRow(title: "Calories:", value: caloriesText)
                InfoRow(title: "Burned Calories:", value: burnedCaloriesText)
                InfoRow(title: "Water:", value: waterText)
            }
            .padding(.horizontal)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 55, style: .continuous)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 45)
        // Apply scale and blur effects for the expanding card animation.
        .scaleEffect(cardScale)
        .blur(radius: cardBlur)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                cardScale = 1.0
                cardBlur = 0.0
            }
        }
    }
    
    // Helper to display the full date.
    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    var title: String
    var value: String
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
