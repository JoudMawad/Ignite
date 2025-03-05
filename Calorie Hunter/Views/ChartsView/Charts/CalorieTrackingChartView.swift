import SwiftUI
import Charts

struct CalorieTrackingChartView: View {
    @ObservedObject var viewModel: FoodViewModel
    private let historyManager = CalorieHistoryManager()
    
    @State private var selectedTimeframe: Timeframe = .week
    
    var calorieData: [(date: String, calories: Int)] {
        historyManager.totalCaloriesForPeriod(days: selectedTimeframe.days)
    }
    
    var formattedData: [(label: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Generate past 7 days (from yesterday back)
        let last7Days = (0..<7).map { offset -> (String, Int) in
            let date = calendar.date(byAdding: .day, value: -offset, to: yesterday)!
            let dateString = ChartDataHelper.dateToString(date)

            let calories = calorieData.first(where: { $0.date == dateString })?.calories ?? 0
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"

            return (weekdayFormatter.string(from: date), calories)
        }

        switch selectedTimeframe {
        case .week:
            return last7Days.reversed() // Ensure correct order (earliest to latest)
        case .month:
            return ChartDataHelper.groupData(from: calorieData, days: 30, interval: 5, dateFormat: "MMM d")
        case .year:
            return ChartDataHelper.groupData(from: calorieData, days: 365, interval: 90, dateFormat: "MMM yyyy")
        }
    }


    
    func maxCalorieValue() -> Int {
        let maxValue = formattedData.map { $0.calories }.max() ?? 100
        return maxValue + 50
    }
    
    var body: some View {
        VStack {
            
            
            ChartCardView {
                VStack {
                    
                    Text("Calorie Consumption")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.15)) // Background color with rounded corners
                            .frame(width: 320,height: 37)
                            .blur(radius: 10)// Adjust height if needed

                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.vertical, 1)
                    }

                    
                    Chart {
                        ForEach(formattedData, id: \.label) { entry in
                            LineMark(
                                x: .value("Date", entry.label),
                                y: .value("Calories", entry.calories)
                            )
                            .interpolationMethod(.monotone)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .symbol(.circle)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .modifier(CustomChartStyle())
                    .chartYScale(domain: 0...maxCalorieValue())
                    .frame(height: 250)
                    .padding()
                    

                    
                }
            }
        }
        .padding(.vertical)
    }
}


struct CalorieTrackingChart_Previews: PreviewProvider {
    static var previews: some View {
        UserDefaults.standard.set([
            "2025-03-01": 1800,
            "2025-03-02": 2000,
            "2025-03-03": 1750,
            "2025-03-04": 2200,
            "2025-03-05": 1900,
            "2025-03-06": 2100,
            "2025-02-27": 1850,
            "2025-02-28": 2500
        ], forKey: "dailyCaloriesHistory")
        
        return CalorieTrackingChartView(viewModel: FoodViewModel())
            .preferredColorScheme(.dark)
    }
}
