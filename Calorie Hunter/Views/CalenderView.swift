import SwiftUI

struct CalendarView: View {
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var stepsViewModel: StepsViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    @ObservedObject var waterViewModel: WaterViewModel
    @ObservedObject var foodViewModel: FoodViewModel

    @Environment(\.colorScheme) var colorScheme

    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil

    // Computes the days in the current month, including nils for grid spacing.
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        // Prepend nils so the first day appears in the correct weekday column.
        var days: [Date?] = Array(repeating: nil, count: calendar.component(.weekday, from: firstOfMonth) - 1)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        // Append nils to fill the grid.
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Month header with navigation buttons.
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentDate))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(MeshGradient(
                                    width: 3,
                                    height: 3,
                                    points: [
                                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                        [0.0, 0.5], [0.9, 0.3], [1.0, 0.5],
                                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                                    ],
                                    colors: [
                                        .green, .blue, .green,
                                        .green, .blue, .blue,
                                        .black, .black, .black
                                    ]
                                ))
                                .frame(width: 180, height: 40)
                        )
                    
                    Spacer()
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.primary)
                }
                .padding()
                
                // Weekday header and calendar grid.
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(daysInMonth.indices, id: \.self) { index in
                        if let date = daysInMonth[index] {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 20, weight: .medium))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
            )
            .padding()
            // Blur the calendar grid when the detail card is visible.
            .blur(radius: selectedDate != nil ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: selectedDate)
            
            // Detail Card Overlay.
            if let date = selectedDate {
                // Semi-transparent background to dismiss the card.
                (colorScheme == .dark ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedDate = nil
                        }
                    }
                
                // Centered detail card with a scale transition.
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
                .transition(.scale)
            }
        }
    }
    
    // Helper to format the current month and year.
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    // Adjust the currentDate by adding/subtracting months.
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
