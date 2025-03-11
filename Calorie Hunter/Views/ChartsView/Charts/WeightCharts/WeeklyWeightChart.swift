import SwiftUI
import Charts

// MARK: - WeeklyWeightChartView
// A SwiftUI view that displays a chart of the user's weight over the past week.
// It uses the provided UserProfile instance to always display today's weight as the user's current weight.
struct WeeklyWeightChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    // Instance of WeightHistoryManager that handles retrieving stored weight data.
    private let weightHistoryManager = WeightHistoryManager()
    
    // The UserProfile instance passed into this view (defined in your separate UserProfile file).
    let userProfile: UserProfile

    // Computed property to retrieve stored weight entries for the past 7 days.
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    // Computed property that formats weight data for display on the chart.
    // For today's date, it always uses the currentWeight from the user profile.
    var formattedData: [(label: String, weight: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset -> (String, Double)? in
            // Calculate the date for each day in the last 7 days.
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            
            // Formatter to create a weekday label (e.g., "Mon", "Tue").
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            
            let weight: Double
            if calendar.isDate(date, inSameDayAs: today) {
                // For today's date, always use the currentWeight from the user's profile.
                weight = userProfile.currentWeight
            } else {
                // For past days, use the stored weight if available.
                // If no stored value exists, fall back to the currentWeight from the profile.
                weight = weightData.first(where: { $0.date == dateString })?.weight ?? userProfile.currentWeight
            }
            // Return a tuple with the weekday label and the corresponding weight.
            return (weekdayFormatter.string(from: date), weight)
        }
        .reversed() // Reverse to display in chronological order.
    }
    
    // Function to calculate the maximum weight for the chart's y-axis.
    // It adds a padding of 1 unit above the maximum value.
    func maxWeightValue() -> Double {
        let maxValue = formattedData.map { $0.weight }.max() ?? 100
        return maxValue + 1
    }
    
    // Function to calculate the minimum weight for the chart's y-axis.
    // It subtracts 1 unit below the minimum value.
    func minWeightValue() -> Double {
        let minValue = formattedData.map { $0.weight }.min() ?? 50
        return minValue - 1
    }
    
    // MARK: - Body
    // The view's main body containing the header texts and the chart.
    var body: some View {
        ChartCardPinkView {
            VStack {
                // Chart header title.
                Text("Weight")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Chart subtitle.
                Text("Week")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // The chart displaying the weight data.
                Chart {
                    // Loop through each data point.
                    ForEach(formattedData, id: \.label) { entry in
                        // Create a line mark for the data point.
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.monotone) // Use smooth interpolation for the line.
                        .lineStyle(StrokeStyle(lineWidth: 3)) // Set the line width.
                        .symbol(.circle) // Mark each data point with a circle.
                        .foregroundStyle(
                            // Apply a linear gradient to the line.
                            LinearGradient(gradient: Gradient(colors: [.purple, .pink]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                    }
                }
                // Customize the x-axis with grid lines, ticks, and labels.
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                // Overlay vertical markers on the chart.
                .overlay(
                    ZStack {
                        // Hardcoded positions for vertical lines (adjust for responsiveness if needed).
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
                // Set the chart's y-axis scale based on the calculated min and max values.
                .chartYScale(domain: minWeightValue()...maxWeightValue())
                .frame(height: 250) // Define the chart's height.
                .padding()
            }
        }
    }
    
    // MARK: - Helper Methods
    /// Retrieves stored weight entries for a given period.
    /// - Parameter days: The number of days to look back.
    /// - Returns: An array of tuples with the formatted date (String) and weight (Double).
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        // Retrieve weight entries from the weight history manager.
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        // Convert each entry's date to a formatted string and pair it with its weight.
        return allWeights.map { (ChartDataHelper.dateToString(ChartDataHelper.stringToDate($0.date)), $0.weight) }
    }
}
