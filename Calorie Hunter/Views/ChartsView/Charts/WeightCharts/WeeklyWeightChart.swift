import SwiftUI
import Charts

struct WeeklyWeightChartView: View {
    @Environment(\.colorScheme) var colorScheme
    // Use the shared WeightHistoryManager for stored weight data.
    @ObservedObject private var weightHistoryManager = WeightHistoryManager.shared
    
    // Accept a user profile view model that contains the active user profile.
    @ObservedObject var viewModel: UserProfileViewModel
    
    // Computed property for the active user profile.
    var profile: UserProfile {
        viewModel.profile ?? UserProfile.defaultProfile
    }
    
    // Retrieve stored weight entries for the past 7 days.
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    // Format weight data for display:
    // For each of the last 7 days, if it’s today, use the profile’s current weight;
    // otherwise, use the stored weight (if available), falling back to the profile’s weight.
    var formattedData: [(label: String, weight: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset -> (String, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            let weight: Double = calendar.isDate(date, inSameDayAs: today)
                ? profile.currentWeight
                : (weightData.first(where: { $0.date == dateString })?.weight ?? profile.currentWeight)
            return (weekdayFormatter.string(from: date), weight)
        }
        .reversed()
    }
    
    // Y-axis scaling helpers.
    func maxWeightValue() -> Double {
        let maxValue = formattedData.map { $0.weight }.max() ?? 100
        return maxValue + 1
    }
    
    func minWeightValue() -> Double {
        let minValue = formattedData.map { $0.weight }.min() ?? 50
        return minValue - 1
    }
    
    var body: some View {
        ChartCardPinkView {
            VStack {
                Text("Weight")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Week")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(formattedData, id: \.0) { entry in
                        LineMark(
                            x: .value("Date", entry.0),
                            y: .value("Weight", entry.1)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .top,
                                endPoint: .bottom)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .overlay(
                    ZStack {
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
                .chartYScale(domain: minWeightValue()...maxWeightValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
    
    // Helper: Retrieve stored weights from the shared WeightHistoryManager.
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map { entry in
            let date = ChartDataHelper.stringToDate(entry.date) ?? Date()
            return (ChartDataHelper.dateToString(date), entry.weight)
        }
    }
}
