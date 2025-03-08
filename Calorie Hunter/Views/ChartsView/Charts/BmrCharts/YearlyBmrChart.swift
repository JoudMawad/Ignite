//
//  YearlyBmrChart.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 08.03.25.
//

import SwiftUI
import Charts

struct YearlyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    private let weightHistoryManager = WeightHistoryManager()

    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    // Group the weight data for the year.
    var formattedData: [(label: String, avgWeight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 365, interval: 90, dateFormat: "MMM yy")
    }
    
    // Compute BMR for each group using the average weight.
    var bmrData: [(label: String, bmr: Double)] {
        formattedData.map { group in
            let bmr = BMRCalculator.computeBMR(
                forWeight: group.avgWeight,
                age: Double(viewModel.age),
                height: Double(viewModel.height),
                gender: viewModel.gender
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
                Text("Year")
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
                        AxisGridLine().foregroundStyle(Color.black)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 51, 101, 151, 202, 252]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 4, height: 21)
                                .foregroundColor(.black)
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

struct YearlyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}
