//
//  CalorieTrackingChartView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI
import Charts

struct CalorieTrackingChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var calorieData: [(date: String, calories: Int)] {
        viewModel.totalCaloriesForPeriod(days: selectedTimeframe.days)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        switch selectedTimeframe {
        case .week:
            return calorieData.suffix(7).map { entry in
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEE" // Short day name (Mon, Tue, etc.)
                return (weekdayFormatter.string(from: stringToDate(entry.date)), entry.calories)
            }
        case .month:
            return calorieData.suffix(30).compactMap { (entry) in
                let day = Calendar.current.component(.day, from: stringToDate(entry.date))
                let importantDays = [1, 5, 10, 15, 20, 25]
                return importantDays.contains(day) ? (String(day), entry.calories) : nil
            }
        case .year:
            return calorieData.suffix(365).compactMap { entry in
                let date = stringToDate(entry.date)
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM" // Short month name (Jan, Feb, Mar, etc.)

                let monthNumber = Calendar.current.component(.month, from: date)
                let currentMonth = Calendar.current.component(.month, from: Date())

                // Ensure only one data point per month by taking the first occurrence
                return monthNumber != currentMonth ? (monthFormatter.string(from: date), entry.calories) : nil
            }

        }
    }
    
    func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
    
    func maxCalorieValue() -> Int {
        let maxValue = formattedData.map { $0.calories }.max() ?? 100
        return maxValue + 50 // Adding a margin for better visualization
    }
    
    var body: some View {
        VStack {
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \ .self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Chart {
                ForEach(formattedData, id: \.label) { entry in
                    LineMark(
                        x: .value("Date", entry.label),
                        y: .value("Calories", entry.calories)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: 0...maxCalorieValue()) // Ensuring y-axis has a defined range
            .frame(height: 300)
            .padding()
        }
    }
}

struct CalorieTrackingChart_Previews: PreviewProvider {
    static var previews: some View {
        CalorieTrackingChartView(viewModel: FoodViewModel())
    }
}

