import SwiftUI
import Charts

struct MonthlyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    private let weightHistoryManager = WeightHistoryManager()
    
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(
            from: weightData,
            days: 30,
            interval: 5,
            outputDateFormat: "MMM d"
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
                subtitle: "Month",
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

struct MonthlyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
