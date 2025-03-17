import SwiftUI
import Charts

struct WeeklyWeightChartView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    @ObservedObject var viewModel: UserProfileViewModel
    
    var profile: UserProfile {
        viewModel.profile ?? UserProfile.defaultProfile
    }
    
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    var formattedData: [(label: String, weight: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (1..<8).compactMap { offset -> (String, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            let weight = weightData.first(where: { $0.date == dateString })?.weight ?? profile.currentWeight
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), weight)
        }
        .reversed()
    }
    
    func maxWeightValue() -> Double {
        (formattedData.map { $0.weight }.max() ?? 100) + 1
    }
    
    func minWeightValue() -> Double {
        (formattedData.map { $0.weight }.min() ?? 50) - 1
    }
    
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map { entry in
            let date = ChartDataHelper.stringToDate(entry.date) ?? Date()
            return (ChartDataHelper.dateToString(date), entry.weight)
        }
    }
    
    var body: some View {
        ChartCardPinkView {
            BaseChartView(
                title: "Weight",
                subtitle: "Week",
                yDomain: minWeightValue()...maxWeightValue(),
                chartContent: {
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
                        .commonStyle(gradientColors: [.purple, colorScheme == .dark ? Color.white : Color.black])
                    }
                }
            )
        }
    }
}

struct WeeklyWeightChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyWeightChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
