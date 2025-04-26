import SwiftUI

/// A calendar view that displays the days of the current month in a grid layout,
/// allows month navigation, and shows detailed information for a selected day.
struct CalendarView: View {
    // MARK: - Observed Objects
    
    /// The view model for managing user profile data.
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    
    /// The view model for tracking user steps.
    @ObservedObject var stepsViewModel: StepsViewModel
    
    /// The view model for tracking burned calories.
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    
    /// The view model for tracking water intake.
    @ObservedObject var waterViewModel: WaterViewModel
    
    /// The view model for managing food-related data.
    @ObservedObject var foodViewModel: FoodViewModel

    // MARK: - Environment
    
    /// Access the current color scheme (light or dark) for styling.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - State Properties
    
    /// Holds the currently displayed date (used for calculating the month to display).
    @State private var currentDate = Date()
    
    /// Stores the date selected by the user for displaying detailed day information.
    @State private var selectedDate: Date? = nil

    // MARK: - Computed Properties
    
    /// Computes the array of days for the current month as an optional Date.
    /// Nils are inserted at the beginning and end to align the grid with weekdays.
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        // Get the first day of the current month.
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        // Get the range of days in the current month.
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        // Prepend nils so that the first day is positioned correctly according to its weekday.
        var days: [Date?] = Array(repeating: nil, count: calendar.component(.weekday, from: firstOfMonth) - 1)
        // Append actual dates for each day in the month.
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        // Append nils to complete the grid row if needed.
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack {
                // MARK: - Month Header
                
                HStack {
                    // Button to navigate to the previous month.
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    
                    Spacer()
                    
                    // Display the current month and year.
                    Text(monthYearString(from: currentDate))
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding()
                    
                    Spacer()
                    
                    // Button to navigate to the next month.
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                }                
                // MARK: - Calendar Grid
                
                // Define a grid layout with 7 columns (one per weekday).
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    // Weekday header labels.
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Calendar days. Use indices of daysInMonth array to support nil placeholders.
                    ForEach(daysInMonth.indices, id: \.self) { index in
                        if let date = daysInMonth[index] {
                            // Each day is a button that, when tapped, shows the day detail card.
                            Button(action: {
                                // Animate the selection of a date.
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 20, weight: .medium))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            // Empty placeholder for grid spacing.
                            Color.clear.frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding()
            }
            
            
            .padding()
            // Blur the calendar grid when the day detail card is visible.
            .blur(radius: selectedDate != nil ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: selectedDate)
            
            // MARK: - Day Detail Overlay
            
            // If a date is selected, display a detail card overlay.
            if let date = selectedDate {
                // Semi-transparent background that dismisses the detail card when tapped.
                (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedDate = nil
                        }
                    }
                
                // Center the detail card vertically with a scale transition effect.
                VStack {
                    Spacer()
                    DayDetailCardView(
                        date: date,
                        userProfileViewModel: userProfileViewModel,
                        burnedCaloriesViewModel: burnedCaloriesViewModel,
                        waterViewModel: waterViewModel,
                        foodViewModel: foodViewModel
                    )
                    Spacer()
                }
                .padding()
                .transition(.blurScale)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.primary)
                .shadow(radius: 3)
        )
    }
    
    // MARK: - Helper Methods
    
    /// Formats a given date into a "Month Year" string.
    /// - Parameter date: The date to format.
    /// - Returns: A string representation in "LLLL yyyy" format.
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    /// Changes the current displayed month by a given value.
    /// - Parameter value: The number of months to add (or subtract if negative).
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = UserProfileViewModel()
        let stepsVM = StepsViewModel()
        let burnedCaloriesVM = BurnedCaloriesViewModel()
        let waterVM = WaterViewModel(container: PersistenceController.shared.container)
        let foodVM = FoodViewModel()
        
        NavigationView {
            CalendarView(
                userProfileViewModel: profileVM,
                stepsViewModel: stepsVM,
                burnedCaloriesViewModel: burnedCaloriesVM,
                waterViewModel: waterVM,
                foodViewModel: foodVM
            )
        }
    }
}
