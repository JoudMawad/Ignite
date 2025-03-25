import SwiftUI
import Charts

// MonthlyBMRChartView displays a line chart of the user's Basal Metabolic Rate (BMR) over a month.
// It uses weight history data, groups it into intervals, calculates BMR values, and renders them.
struct MonthlyBMRChartView: View {
    // Observed view model providing the user profile data (age, height, gender) required for BMR calculation.
    @ObservedObject var viewModel: UserProfileViewModel
    // Access the current color scheme (light or dark) to adapt chart colors.
    @Environment(\.colorScheme) var colorScheme
    // WeightHistoryManager instance to fetch historical weight data.
    private let weightHistoryManager = WeightHistoryManager()
    
    // Retrieve weight data for the past 30 days as an array of (date, weight) tuples.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    // Group the weight data into intervals (e.g., every 5 days) and calculate the average weight for each group.
    // The dates are formatted using the specified output format ("MMM d").
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
        )
        .map { (label: $0.label, avgWeight: $0.weight) }
    }
    
    // Calculate BMR for each data group using the user's profile details.
    // This maps each group label to its corresponding computed BMR value.
    var bmrData: [(label: String, bmr: Double)] {
        formattedData.map { group in
            let bmr = BMRCalculator.computeBMR(
                forWeight: group.avgWeight,
                age: Double(viewModel.profile?.age ?? 25),      // Default age if profile is unavailable.
                height: Double(viewModel.profile?.height ?? 170), // Default height if profile is unavailable.
                gender: viewModel.profile?.gender ?? "M"          // Default gender if profile is unavailable.
            )
            return (group.label, bmr)
        }
    }
    
    // Compute the maximum BMR value among the entries, with a buffer of +50 to provide padding on the chart.
    func maxBMRValue() -> Double {
        (bmrData.map { $0.bmr }.max() ?? 1500) + 50
    }
    
    // Compute the minimum BMR value among the entries, with a buffer of -50 for chart padding.
    func minBMRValue() -> Double {
        (bmrData.map { $0.bmr }.min() ?? 1200) - 50
    }
    
    // Main view body which composes the chart within a styled card.
    var body: some View {
        // ChartCardYellowView provides a yellow-themed card wrapper for visual consistency.
        ChartCardYellowView {
            // BaseChartView is a custom view that sets up the chart with title, subtitle, and y-axis domain.
            BaseChartView(
                title: "BMR",
                subtitle: "Month",
                yDomain: minBMRValue()...maxBMRValue(),
                chartContent: {
                    // Iterate over each BMR data entry and plot a line mark for each.
                    ForEach(bmrData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("BMR", entry.bmr)
                        )
                        // Apply a common style using a gradient from yellow to an appropriate color based on the color scheme.
                        .commonStyle(gradientColors: [.yellow, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct MonthlyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
