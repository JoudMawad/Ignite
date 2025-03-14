import SwiftUI

struct CustomAlert: View {
    var title: String
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 16)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            Button(action: {
                onDismiss()
            }) {
                Text("Got it!")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
        .background(Color.black.opacity(1))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
}
