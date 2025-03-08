//
//  ChartCardView.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import SwiftUI

struct ChartCardCyanView<Content: View>: View {
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
                    .shadow(color: Color.cyan.opacity(0.15), radius: 5, x: 0, y: 4)
            )
    }
}

struct ChartCardYellowView<Content: View>: View {
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
                    .shadow(color: Color.yellow.opacity(0.15), radius: 5, x: 0, y: 4)
            )
    }
}

struct ChartCardRedView<Content: View>: View {
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
                    .shadow(color: Color.red.opacity(0.15), radius: 5, x: 0, y: 4)
            )
    }
}

struct ChartCardPinkView<Content: View>: View {
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
                    .shadow(color: Color.pink.opacity(0.15), radius: 5, x: 0, y: 4)
            )
    }
}
