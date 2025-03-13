import SwiftUI
import Charts

struct MonthlyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    private let weightHistoryManager = WeightHistoryManager()
    
    // Retrieve stored weight data for the past 30 days.
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 30)
    }
    
    // Group the weight data for the month.
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 30, interval: 5, dateFormat: "MMM d")
    }
    
    // Compute the monthly BMR using the average weight of each group.
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
        let maxBMR = bmrData.map { $0.bmr }.max() ?? 1500
        return maxBMR + 50
    }
    
    func minBMRValue() -> Double {
        let minBMR = bmrData.map { $0.bmr }.min() ?? 1200
        return minBMR - 50
    }
    
    var body: some View {
        ChartCardYellowView {
            VStack {
                Text("BMR")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Month")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Chart {
                    ForEach(bmrData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("BMR", entry.bmr)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .yellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
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
                        let positions: [CGFloat] = [0, 42, 84, 126, 168, 210, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3.5, height: 21)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .blendMode(.normal)
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: minBMRValue()...maxBMRValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct MonthlyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
