import SwiftUI
import Charts

/// A view that displays a yearly BMR chart by grouping weight data over 90-day intervals.
struct YearlyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // Manager to retrieve weight history data for the user.
    private let weightHistoryManager = WeightHistoryManager()

    /// Retrieve weight data for the past year.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    /// Group the yearly weight data into 90-day intervals and format the label for display.
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
        .map { (label: $0.label, avgWeight: $0.weight) }
    }
    
    /// Compute BMR for each interval based on the average weight and user profile data.
    var bmrData: [(label: String, bmr: Double)] {
        formattedData.map { group in
            let bmr = BMRCalculator.computeBMR(
                forWeight: group.avgWeight,
                age: Double(viewModel.profile?.age ?? 25),
                height: Double(viewModel.profile?.height ?? 170),
                gender: viewModel.profile?.gender ?? "M"
            )
            return (group.label, bmr)
        }
    }
    
    /// Calculate a maximum BMR value for chart scaling with added padding.
    func maxBMRValue() -> Double {
        (bmrData.map { $0.bmr }.max() ?? 1500) + 50
    }
    
    /// Calculate a minimum BMR value for chart scaling with subtracted padding.
    func minBMRValue() -> Double {
        (bmrData.map { $0.bmr }.min() ?? 1200) - 50
    }
    
    /// Define the view's body, displaying the BMR line chart over the year.
    var body: some View {
        ChartCardYellowView {
            BaseChartView(
                title: "BMR",
                subtitle: "Year",
                yDomain: minBMRValue()...maxBMRValue(),
                chartContent: {
                    ForEach(bmrData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("BMR", entry.bmr)
                        )
                        // Apply a common gradient style based on the current color scheme.
                        .commonStyle(gradientColors: [.yellow, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct YearlyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
