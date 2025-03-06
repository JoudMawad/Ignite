//
//  YearlyCalorieTrackingChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import SwiftUI
import Charts

struct YearlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 365)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupData(from: calorieData, days: 365, interval: 90, dateFormat: "MMM yy")
    }

    func maxCalorieValue() -> Int {
        return (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardView {
            VStack {
                Text("Calories")
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
                            y: .value("Calories", entry.calories)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol(.circle)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine()
                                        .foregroundStyle(Color.black) // Makes vertical grid lines black
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
                .chartYScale(domain: 0...maxCalorieValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct YearlyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        YearlyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}

