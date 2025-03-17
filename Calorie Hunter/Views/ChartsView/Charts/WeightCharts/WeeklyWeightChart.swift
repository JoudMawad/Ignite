import SwiftUI
import Charts

/// A view that displays a weekly weight chart using stored weight data and user profile information.
/// The chart shows weight for each day (excluding today) over the past 7 days, using a line chart with custom styling.
struct WeeklyWeightChartView: View {
    // Access the current color scheme to adjust colors based on dark/light mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// The shared manager responsible for retrieving stored weight data.
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    
    /// The user profile view model, which contains the active user profile.
    @ObservedObject var viewModel: UserProfileViewModel
    
    /// Computed property that returns the active user profile,
    /// or a default profile if none is set.
    var profile: UserProfile {
        viewModel.profile ?? UserProfile.defaultProfile
    }
    
    /// Retrieves stored weight entries for the past 7 days.
    /// This uses a helper function to get the data from the weight history manager.
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    /// Formats the raw weight data for display in the chart.
    ///
    /// - It excludes today's data by iterating offsets from 1 to 7.
    /// - For each offset, it calculates the date, converts it to a short weekday string (e.g. "Mon"),
    ///   and retrieves the stored weight for that day.
    /// - If no stored weight is found, it falls back to the profile's current weight.
    /// - The resulting array is reversed so the chart displays days in chronological order.
    var formattedData: [(label: String, weight: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (1..<8).compactMap { offset -> (String, Double)? in
            // Calculate the date for the given offset (1 = yesterday, 7 = 7 days ago)
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            // Convert the date to a string format (used for matching stored data)
            let dateString = ChartDataHelper.dateToString(date)
            // Prepare a formatter to display the weekday (e.g., "Mon")
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            // Retrieve the stored weight for this date if available; otherwise, use current profile weight.
            let weight: Double = weightData.first(where: { $0.date == dateString })?.weight ?? profile.currentWeight
            return (weekdayFormatter.string(from: date), weight)
        }
        .reversed()
    }
    
    /// Computes the maximum Y-axis value for the chart,
    /// adding a small headroom of 1 unit.
    func maxWeightValue() -> Double {
        let maxValue = formattedData.map { $0.weight }.max() ?? 100
        return maxValue + 1
    }
    
    /// Computes the minimum Y-axis value for the chart,
    /// subtracting a small headroom of 1 unit.
    func minWeightValue() -> Double {
        let minValue = formattedData.map { $0.weight }.min() ?? 50
        return minValue - 1
    }
    
    var body: some View {
        // Wrap the chart inside a card view for consistent styling.
        ChartCardPinkView {
            VStack {
                // Title for the chart.
                Text("Weight")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                // Subtitle for the chart.
                Text("Week")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // The chart displaying weight data.
                Chart {
                    ForEach(formattedData, id: \.label) { entry in
                        // Create a line mark for each day's weight.
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, colorScheme == .dark ? Color.white : Color.black]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                // Configure the chart's X-axis with grid lines, ticks, and labels.
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                // Add an overlay with vertical rectangles for additional styling.
                .overlay(
                    ZStack {
                        // Predefined positions for overlay elements.
                        let positions: [CGFloat] = [0, 36, 72, 108, 145, 180, 216, 253]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3, height: 21)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                // Set the Y-axis scale dynamically based on the min and max weight.
                .chartYScale(domain: minWeightValue()...maxWeightValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
    
    /// Helper function to retrieve stored weight data for a given period.
    ///
    /// - Parameter days: The number of days in the past to retrieve data for.
    /// - Returns: An array of tuples containing the date (as a string) and weight.
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map { entry in
            let date = ChartDataHelper.stringToDate(entry.date) ?? Date()
            return (ChartDataHelper.dateToString(date), entry.weight)
        }
    }
}
