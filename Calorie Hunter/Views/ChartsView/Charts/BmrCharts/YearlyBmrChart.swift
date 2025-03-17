import SwiftUI
import Charts

struct YearlyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    private let weightHistoryManager = WeightHistoryManager()

    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
        .map { (label: $0.label, avgWeight: $0.weight) }
    }
    
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
    
    func maxBMRValue() -> Double {
        (bmrData.map { $0.bmr }.max() ?? 1500) + 50
    }
    
    func minBMRValue() -> Double {
        (bmrData.map { $0.bmr }.min() ?? 1200) - 50
    }
    
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
