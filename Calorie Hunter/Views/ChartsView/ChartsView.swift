//
//  ChartsView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

struct ChartsView: View {
    @ObservedObject var viewModel: FoodViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CalorieTrackingChartView(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("Charts")
        }
    }
}

#Preview {
    ChartsView(viewModel: FoodViewModel())
}

