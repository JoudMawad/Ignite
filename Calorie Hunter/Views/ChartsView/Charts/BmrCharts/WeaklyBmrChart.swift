//
//  WeaklyBmrChart.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 08.03.25.
//

import SwiftUI
import Charts

struct WeeklyBMRChartView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    private let weightHistoryManager = WeightHistoryManager()
    
    /// Retrieve stored weight data for the last 7 days.
    private func getStoredWeightsForPeriod(days: Int) -> [(date: String, weight: Double)] {
        let allWeights = weightHistoryManager.weightForPeriod(days: days)
        return allWeights.map { (ChartDataHelper.dateToString(ChartDataHelper.stringToDate($0.date)), $0.weight) }
    }
    
    /// Weight data for the week.
    var weightData: [(date: String, weight: Double)] {
        getStoredWeightsForPeriod(days: 7)
    }
    
    /// For each day in the past week, compute the BMR using the separated BMRCalculator.
    var formattedData: [(label: String, bmr: Double)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset -> (String, Double)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dateString = ChartDataHelper.dateToString(date)
            // Use stored weight if available; otherwise, fall back on current weight.
            let weight = weightData.first(where: { $0.date == dateString })?.weight ?? viewModel.currentWeight
            let bmr = BMRCalculator.computeBMR(
                forWeight: weight,
                age: Double(viewModel.age),
                height: Double(viewModel.height),
                gender: viewModel.gender
            )
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (weekdayFormatter.string(from: date), bmr)
        }.reversed()
    }
    

    /// Calculate dynamic Y-axis maximum.
    func maxBMRValue() -> Double {
        let maxValue = formattedData.map { $0.bmr }.max() ?? 1500
        return maxValue + 50
    }
    
    /// Calculate dynamic Y-axis minimum.
    func minBMRValue() -> Double {
        let minValue = formattedData.map { $0.bmr }.min() ?? 1200
        return minValue - 50
    }
    
    var body: some View {
        ChartCardYellowView {
            VStack {
                Text("BMR")
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
                    ForEach(formattedData, id: \.label) { entry in
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
                        let positions: [CGFloat] = [0, 36, 71, 106, 141, 175, 210, 244]
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3, height: 21)
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

struct WeeklyBMRChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyBMRChartView(viewModel: UserProfileViewModel())
            .preferredColorScheme(.dark)
    }
}

