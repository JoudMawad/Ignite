//
//  CustomChartStyleHelper.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI
import Charts

struct CustomChartStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
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
                    let positions: [CGFloat] = [0, 40, 80, 120, 160, 205, 245, 280] // Control positions
                    
                    ForEach(positions, id: \.self) { x in
                        Rectangle()
                            .frame(width: 10, height: 20)
                            .foregroundColor(.black)
                            .blendMode(.normal) // Ensures black rendering
                            .position(x: x, y: 242)
                    }
                }
            )
    }
}

