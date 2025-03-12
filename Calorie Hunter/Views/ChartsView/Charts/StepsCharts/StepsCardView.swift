import SwiftUI

struct StepsCardView: View {
    @ObservedObject var stepsViewModel: StepsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                Text("Steps")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text("\(stepsViewModel.currentSteps)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(colorScheme == .dark ? .black : .white)
            Spacer()
        }
        .padding()
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? .white : .black)
                .shadow(radius: 3)
        )
    }
}
