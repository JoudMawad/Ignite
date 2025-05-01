import SwiftUI
import CoreData
import UIKit

/// Shared haptic feedback generators.
private let successFeedback = UINotificationFeedbackGenerator()
private let errorFeedback   = UINotificationFeedbackGenerator()

struct CalendarView: View {
    // MARK: – Observed ViewModels
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    @ObservedObject var stepsViewModel: StepsViewModel
    @ObservedObject var burnedCaloriesViewModel: BurnedCaloriesViewModel
    @ObservedObject var waterViewModel: WaterViewModel

    // MARK: – Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context

    // MARK: – State
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    @State private var showFullOverview: Bool = false

    private let goalsManager = GoalsManager.shared

    /// Namespace for matched-geometry effect when expanding a day cell.
    @Namespace private var dayTransition

    /// Haptic feedback generator for calendar navigation taps.
    private let tapFeedback = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Appearance
    /// Diameter for the status indicator circle.
    private let statusCircleDiameter: CGFloat = 9

    /// Width and height for each calendar cell
    private let cellSize: CGFloat = 44

    // MARK: – Computed
    private var daysInMonth: [Date?] {
        let cal = Calendar.current
        guard let first = cal.date(from: cal.dateComponents([.year, .month], from: currentDate)) else { return [] }
        let range = cal.range(of: .day, in: .month, for: currentDate)!
        var days: [Date?] = Array(repeating: nil, count: cal.component(.weekday, from: first) - 1)
        for d in 1...range.count {
            days.append(cal.date(byAdding: .day, value: d - 1, to: first))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    // MARK: – Body
    var body: some View {
        ZStack {
            // Summary view behind calendar
            if let date = selectedDate {
                DaySummaryView(
                    date: date,
                    userProfileVM: userProfileViewModel,
                    burnedCaloriesVM: burnedCaloriesViewModel,
                    waterVM: waterViewModel,
                    stepsVM: stepsViewModel,
                    context: context,
                    onClose: {
                        withAnimation { selectedDate = nil }
                    },
                    onFullOverview: {
                        showFullOverview = true
                    }
                )
            }
            
            // Calendar view on top, only when no date is selected
            if selectedDate == nil {
                VStack(spacing: 10) {
                    calendarHeader
                    calendarGrid
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? .white : .black)
                )
                .transition(.move(edge: .top))
                .fullScreenCover(isPresented: $showFullOverview) {
                    if let date = selectedDate {
                        DayDetailCardView(
                            date: date,
                            userProfileViewModel: userProfileViewModel,
                            burnedCaloriesViewModel: burnedCaloriesViewModel,
                            waterViewModel: waterViewModel,
                            stepsViewModel: stepsViewModel,
                            context: context
                        ) {
                            showFullOverview = false
                            selectedDate = nil
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 3)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: selectedDate)
    }

    // MARK: – Subviews
    private var calendarHeader: some View {
            
        HStack {
            Button {
                tapFeedback.impactOccurred()
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                  .font(.system(size: 20, weight: .bold, design: .rounded))
                  .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            Spacer()
            Text(monthYearString(from: currentDate))
              .font(.system(size: 24, weight: .bold, design: .rounded))
              .foregroundColor(colorScheme == .dark ? .black : .white)
            Spacer()
            Button {
                tapFeedback.impactOccurred()
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                  .font(.system(size: 20, weight: .bold, design: .rounded))
                  .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.bottom, 9)
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 10) {
            let weekdays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            ForEach(weekdays, id: \.self) { wd in
                Text(wd)
                  .font(.system(size: 14, weight: .bold))
                  .frame(width: cellSize, height: cellSize * 0.6)
                  .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            ForEach(daysInMonth.indices, id: \.self) { idx in
                if let day = daysInMonth[idx] {
                    // Determine if the day is strictly before today
                    let startOfDay = Calendar.current.startOfDay(for: Date())
                    let isPastDay = day < startOfDay

                    Group {
                        if isPastDay {
                            Button {
                                tapFeedback.impactOccurred()
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedDate = day
                                }
                            } label: {
                                ZStack {
                                    Capsule()
                                      .fill(
                                        Calendar.current.isDateInToday(day)
                                          ? Color.blue.opacity(0.3)
                                          : Color.gray.opacity(0.3)
                                      )
                                      .matchedGeometryEffect(id: "\(day)-bg", in: dayTransition)
                                    VStack(spacing: 4) {
                                        Text("\(Calendar.current.component(.day, from: day))")
                                          .font(.system(size: 14, weight: .bold))
                                          .foregroundColor(colorScheme == .dark ? .black : .white)
                                        if day <= startOfDay {
                                            if consumedCaloriesValue(for: day) == 0 {
                                                Circle()
                                                  .stroke(Color.gray, lineWidth: 2)
                                                  .frame(width: statusCircleDiameter, height: statusCircleDiameter)
                                            } else {
                                                Circle()
                                                  .fill(isConsumedUnderGoal(for: day) ? Color.green : Color.red)
                                                  .frame(width: statusCircleDiameter, height: statusCircleDiameter)
                                            }
                                        }
                                    }
                                    .matchedGeometryEffect(id: day, in: dayTransition)
                                }
                                .frame(width: cellSize, height: cellSize)
                            }
                        } else {
                            // Not past: show cell without tappable behavior
                            ZStack {
                                Capsule()
                                  .fill(
                                    Calendar.current.isDateInToday(day)
                                      ? Color.blue.opacity(0.3)
                                      : Color.gray.opacity(0.3)
                                  )
                                  .matchedGeometryEffect(id: "\(day)-bg", in: dayTransition)
                                VStack(spacing: 4) {
                                    Text("\(Calendar.current.component(.day, from: day))")
                                      .font(.system(size: 14, weight: .bold))
                                      .foregroundColor(colorScheme == .dark ? .black : .white)
                                    // Show status only for past or today
                                    if day <= startOfDay {
                                        if consumedCaloriesValue(for: day) == 0 {
                                            Circle()
                                              .stroke(Color.gray, lineWidth: 2)
                                              .frame(width: statusCircleDiameter, height: statusCircleDiameter)
                                        } else {
                                            Circle()
                                              .fill(isConsumedUnderGoal(for: day) ? Color.green : Color.red)
                                              .frame(width: statusCircleDiameter, height: statusCircleDiameter)
                                        }
                                    }
                                }
                                .matchedGeometryEffect(id: day, in: dayTransition)
                            }
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                errorFeedback.notificationOccurred(.error)
                            }
                        }
                    }
                } else {
                    Color.clear.frame(width: cellSize, height: cellSize)
                }
            }
        }
        .padding(.horizontal, 10)
    }

    // MARK: – Helpers
    private func monthYearString(from date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
    private func changeMonth(by n: Int) {
        if let d = Calendar.current.date(byAdding: .month, value: n, to: currentDate) {
            currentDate = d
        }
    }
    private func dateFormattedFull(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: date)
    }
    private func consumedCaloriesValue(for date: Date) -> Double {
        Double(DateFoodViewModel(date: date, context: context).totalCalories)
    }
    private func burnedCaloriesValue(for date: Date) -> Double {
        let iso = DateFormatter.isoDate.string(from: date)
        let history = BurnedCaloriesHistoryManager.shared.burnedCaloriesForPeriod(days: 30)
        if let e = history.first(where: { $0.date == iso }) { return e.burnedCalories }
        else if Calendar.current.isDateInToday(date) { return burnedCaloriesViewModel.currentBurnedCalories }
        else { return 0 }
    }
    private func isConsumedUnderGoal(for date: Date) -> Bool {
        consumedCaloriesValue(for: date) <= goalsManager.goalValue(for: .calories, on: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(
            userProfileViewModel: UserProfileViewModel(),
            stepsViewModel: StepsViewModel(),
            burnedCaloriesViewModel: BurnedCaloriesViewModel(),
            waterViewModel: WaterViewModel(container: PersistenceController.shared.container)
        )
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
