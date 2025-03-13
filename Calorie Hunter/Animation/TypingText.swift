//
//  TypingText.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 12.03.25.
//

import SwiftUI

struct TypingText: View {
    let fullText: String
    @State private var displayedText = ""
    // Adjust the interval to control the speed of the typing effect
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(displayedText)
            .onAppear {
                displayedText = "" // reset on appear if needed
            }
            .onReceive(timer) { _ in
                if displayedText.count < fullText.count {
                    let index = fullText.index(fullText.startIndex, offsetBy: displayedText.count)
                    displayedText += String(fullText[index])
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

