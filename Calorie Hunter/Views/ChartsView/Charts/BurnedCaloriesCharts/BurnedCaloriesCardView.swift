import SwiftUI

struct BurnedCaloriesCardView: View {
    @ObservedObject var viewModel: BurnedCaloriesViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                Text("Burned Calories")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text("\(Int(viewModel.currentBurnedCalories))")
                .font(.system(size: 26, weight: .bold, design: .rounded))
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
