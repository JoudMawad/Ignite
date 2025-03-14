import SwiftUI

struct CountingNumberText: View, Animatable {
    var number: Double

    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    var body: some View {
        Text("\(Int(number))")
            .font(.system(size: 26, weight: .bold, design: .rounded))
    }
}
