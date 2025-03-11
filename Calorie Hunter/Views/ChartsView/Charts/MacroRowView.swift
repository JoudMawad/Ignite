//
//  MacroRowView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

struct MacroRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: Double
    let percentage: Double
    
    var body: some View {
        let colors = ChartGradientHelper.gradientForNutrient(title)
        
        let startColor: Color = colors.first ?? Color.blue
        let endColor: Color = colors.last ?? Color.green

        return HStack {
            // Color Indicator with Gradient
            ZStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let radius = size / 2

                    // Left Half (Start Color)
                    Path { path in
                        path.addArc(center: CGPoint(x: radius, y: radius),
                                    radius: radius,
                                    startAngle: .degrees(180),
                                    endAngle: .degrees(0),
                                    clockwise: false)
                    }
                    .fill(startColor)

                    // Right Half (End Color)
                    Path { path in
                        path.addArc(center: CGPoint(x: radius, y: radius),
                                    radius: radius,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(180),
                                    clockwise: false)
                    }
                    .fill(endColor)
                }
                .frame(width: 12, height: 12)
            }
            .overlay(
                Circle()
                    .stroke(startColor, lineWidth: 2)
                    .blur(radius: 3)
                    .opacity(0.9)
            )

            Text("\(title): \(Int(value))g ")
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

// MARK: - Preview
struct MacroRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            MacroRowView(title: "Protein", value: 50, percentage: 25.0)
            MacroRowView(title: "Carbs", value: 100, percentage: 50.0)
            MacroRowView(title: "Fat", value: 30, percentage: 15.0)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
