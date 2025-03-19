import SwiftUI

struct CustomAlert: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 13) {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .padding(.top, 16)
            
            Divider()
                .padding(.top, -10)
            
            Text(message)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(.primary)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 60)
    }
}

struct CustomAlert_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlert(title: "Alert Title", message: "This is a sample alert message.", onDismiss: {})
    }
}
