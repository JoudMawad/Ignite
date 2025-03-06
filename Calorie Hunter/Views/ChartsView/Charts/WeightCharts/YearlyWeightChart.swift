//
//  YearlyWeightChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import SwiftUI
import Charts

struct YearlyWeightChartView: View {
    private let weightHistoryManager = WeightHistoryManager()
    
    /// ✅ Fetches last 365 days of weight data
    var weightData: [(date: String, weight: Double)] {
        weightHistoryManager.weightForPeriod(days: 365)
    }
    
    /// ✅ Groups weight data into 90-day intervals & formats it correctly
    var formattedData: [(label: String, weight: Double)] {
        ChartDataHelper.groupWeightData(from: weightData, days: 365, interval: 90, dateFormat: "MMM yy")
    }

    /// ✅ Dynamically determines Y-axis max value (prevents incorrect scaling)
    func maxWeightValue() -> Double {
        return (formattedData.map { $0.weight }.max() ?? 100) + 2 // Add buffer
    }

    /// ✅ Dynamically determines Y-axis min value
    func minWeightValue() -> Double {
        return (formattedData.map { $0.weight }.min() ?? 50) - 2 // Add buffer
    }
    
    var body: some View {
        ChartCardPinkView {
            VStack {
                Text("Weight")
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
                    ForEach(formattedData, id: \.label) { entry in
                        LineMark(
                            x: .value("Date", entry.label),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.black)
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .overlay(
                    ZStack {
                        let positions: [CGFloat] = [0, 51, 101, 151, 202, 252] // Control positions
                        
                        ForEach(positions, id: \.self) { x in
                            Rectangle()
                                .frame(width: 3, height: 21)
                                .foregroundColor(.black)
                                .blendMode(.normal) // Ensures black rendering
                                .position(x: x, y: 242)
                        }
                    }
                )
                .chartYScale(domain: minWeightValue()...maxWeightValue()) // ✅ Uses correct scaling
                .frame(height: 250)
                .padding()
            }
        }
    }
}

