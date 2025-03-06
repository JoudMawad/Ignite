//
//  ChartCardView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

struct ChartCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 60)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.cyan.opacity(0.125), radius: 5, x: 0, y: 4)
            )
    }
}
