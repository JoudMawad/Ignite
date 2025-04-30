import SwiftUI
import CoreData

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
    
    
    // MARK: - Environment
    
    /// Access the current color scheme (light or dark) for styling.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    
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
        // One single “card” container
        VStack {
            if let date = selectedDate {
                DayDetailCardView(
                    date: date,
                    userProfileViewModel: userProfileViewModel,
                    burnedCaloriesViewModel: burnedCaloriesViewModel,
                    waterViewModel: waterViewModel, stepsViewModel: stepsViewModel,
                    context: context,
                    onBack: {
                        withAnimation {
                            selectedDate = nil
                        }
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                // Calendar Header
                HStack {
                    Button { changeMonth(by: -1) } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                    }
                    Spacer()
                    Text(monthYearString(from: currentDate))
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Spacer()
                    Button { changeMonth(by: 1) } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                    }
                }
                .padding()
                
                // Calendar Grid
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(daysInMonth.indices, id: \.self) { idx in
                        if let day = daysInMonth[idx] {
                            Button {
                                withAnimation {
                                    selectedDate = day
                                }
                            } label: {
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Color.clear.frame(height: 40)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        .animation(.easeInOut, value: selectedDate)
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
    /// Formats the given date to a medium style string for the detail header.
    /// - Parameter date: The date to format.
    /// - Returns: A medium-style date string.
    private func dateFormattedFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Previews
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        // In-memory Core Data context for previews
        let context = PersistenceController.shared.container.viewContext
        CalendarView(
            userProfileViewModel: UserProfileViewModel(),
            stepsViewModel: StepsViewModel(),
            burnedCaloriesViewModel: BurnedCaloriesViewModel(),
            waterViewModel: WaterViewModel(container: PersistenceController.shared.container)
        )
        .environment(\.managedObjectContext, context)
    }
}
