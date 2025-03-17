import SwiftUI
import Charts

struct WeeklyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    private let weightHistoryManager = WeightHistoryManager()
    
    /// Retrieve stored weight data for the last 7 days.
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map {
            (ChartDataHelper.dateToString(ChartDataHelper.stringToDate($0.date) ?? Date()), $0.weight)
        }
    }
    
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, bmr: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (1..<8).compactMap { offset -> (String, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            let weight = weightData.first(where: { $0.date == dateString })?.weight ?? (viewModel.profile?.currentWeight ?? 70.0)
            let bmr = BMRCalculator.computeBMR(
                forWeight: weight,
                age: Double(viewModel.profile?.age ?? 25),
                height: Double(viewModel.profile?.height ?? 170),
                gender: viewModel.profile?.gender ?? "M"
            )
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), bmr)
        }
        .reversed()
    }
    
    func maxBMRValue() -> Double {
        (formattedData.map { $0.bmr }.max() ?? 1500) + 50
    }
    
    func minBMRValue() -> Double {
        (formattedData.map { $0.bmr }.min() ?? 1200) - 50
    }
    
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
