//
//  MonthlyCalorieTrackingChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 06.03.25.
//

import SwiftUI
import Charts

struct MonthlyCalorieChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: 30)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        ChartDataHelper.groupData(from: calorieData, days: 30, interval: 5, dateFormat: "MMM d")
    }

    func maxCalorieValue() -> Int {
        return (formattedData.map { $0.calories }.max() ?? 100) + 50
    }
    
    var body: some View {
        ChartCardView {
            VStack {
                Text("Monthly Calorie Consumption")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
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
                .modifier(CustomChartStyle())
                .chartYScale(domain: 0...maxCalorieValue())
                .frame(height: 250)
                .padding()
            }
        }
    }
}

struct MonthlyCalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCalorieChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}
