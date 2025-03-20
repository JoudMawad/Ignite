import SwiftUI

struct StatView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            Text(value)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }
        .frame(maxWidth: .infinity)
    }
}
