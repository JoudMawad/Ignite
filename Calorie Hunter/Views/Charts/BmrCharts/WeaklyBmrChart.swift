import SwiftUI
import Charts

/// A view that displays a weekly Basal Metabolic Rate (BMR) chart based on user weight history.
struct WeeklyBMRChartView: View {
    // Observed user profile data, including current weight, age, height, and gender.
    @ObservedObject var viewModel: UserProfileViewModel
    
    // Access the current color scheme to adapt chart styling.
    @Environment(\.colorScheme) var colorScheme
    
    // Manages the retrieval of weight history data.
    private let weightHistoryManager = WeightHistoryManager()
    
    /// Retrieves stored weight entries for a specified number of past days.
    /// - Parameter days: Number of days to look back for weight data.
    /// - Returns: An array of tuples with a formatted date string and the corresponding weight.
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map {
            (ChartDataHelper.dateToString(ChartDataHelper.stringToDate($0.date) ?? Date()), $0.weight)
        }
    }
    
    /// Weight data computed for the past 7 days.
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    /// Prepares the data for chart display by calculating BMR values for each of the past 7 days.
    /// - Returns: An array of tuples where each tuple contains the weekday label and its calculated BMR.
    var formattedData: [(label: String, bmr: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (1..<8).compactMap { offset -> (String, Double)? in
            // Calculate the date for the given day offset.
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            
            // Use stored weight if available; otherwise, fallback to the current weight or a default.
            let weight = weightData.first(where: { $0.date == dateString })?.weight ?? (viewModel.profile?.currentWeight ?? 70.0)
            
            // Calculate the BMR using profile details and the determined weight.
            let bmr = BMRCalculator.computeBMR(
                forWeight: weight,
                age: Double(viewModel.profile?.age ?? 25),
                height: Double(viewModel.profile?.height ?? 170),
                gender: viewModel.profile?.gender ?? "M"
            )
            
            // Format the date to show only the weekday abbreviation.
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), bmr)
        }
        .reversed() // Order data from oldest to most recent.
    }
    
    /// Calculates a buffered maximum BMR value for proper chart scaling.
    /// - Returns: Maximum BMR value from the data plus a padding buffer.
    func maxBMRValue() -> Double {
        (formattedData.map { $0.bmr }.max() ?? 1500) + 50
    }
    
    /// Calculates a buffered minimum BMR value for proper chart scaling.
    /// - Returns: Minimum BMR value from the data minus a padding buffer.
    func minBMRValue() -> Double {
        (formattedData.map { $0.bmr }.min() ?? 1200) - 50
    }
    
    /// Defines the view's body including the chart with proper scaling and styling.
    var body: some View {
        ChartCardYellowView {
            BaseChartView(
                title: "BMR",
                subtitle: "Week",
                yDomain: minBMRValue()...maxBMRValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("BMR", entry.bmr)
                        )
                        .commonStyle(gradientColors: [.yellow, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct WeeklyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
