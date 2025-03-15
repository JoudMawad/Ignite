//
//  YearlyBurnedCaloriesChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 13.03.25.
//

import SwiftUI
import Charts

struct YearlyBurnedCaloriesChartView: View {
    @ObservedObject var burnedCaloriesManager: BurnedCaloriesHistoryManager
    @Environment(\.colorScheme) var colorScheme
    
    /// Last 365 days of raw burned calories data.
    private var rawBurnedCaloriesData: [(date: String, burnedCalories: Double)] {
        burnedCaloriesManager.burnedCaloriesForPeriod(days: 365)
    }
    
    /// Group into 90-day intervals, labeled "MMM yy".
    private var formattedData: [(label: String, burnedCalories: Double)] {
        ChartDataHelper.groupBurnedCaloriesData(
            from: rawBurnedCaloriesData,
            days: 365,
            interval: 90,
            outputDateFormat: "MMM yy"
        )
    }
    
    private func maxBurnedCaloriesValue() -> Double {
        (formattedData.map { $0.burnedCalories }.max() ?? 0) + 50
    }
    
    var body: some View {
        ChartCardRedView {
            VStack {
                Text("Burned Calories")
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
                            y: .value("Burned Calories", entry.burnedCalories)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, colorScheme == .dark ? Color.white : Color.black]),
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
                .chartYScale(domain: 0...maxBurnedCaloriesValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

