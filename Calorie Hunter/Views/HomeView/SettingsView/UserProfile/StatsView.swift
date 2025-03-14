import SwiftUI

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}
