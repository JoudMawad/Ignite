// ActivitySliderView.swift
/*
import SwiftUI
import UIKit

struct ActivitySliderView: View {
    @Environment(\.colorScheme) private var colorScheme

    /// Bound to the current selection (0…3) as an enum.
    @Binding var level: ActivityLevel

    /// Fires whenever the user picks a new level.
    var onLevelChange: ((ActivityLevel) -> Void)? = nil

    /// Match the Gender segmented control appearance.
    init(level: Binding<ActivityLevel>, onLevelChange: ((ActivityLevel) -> Void)? = nil) {
        self._level = level
        self.onLevelChange = onLevelChange

        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.systemBlue
        UISegmentedControl.appearance().backgroundColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Activity")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding(.bottom, 15)

            Picker("", selection: $level) {
                ForEach(ActivityLevel.allCases) { lvl in
                    Text(lvl.title).tag(lvl)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
        }
        .frame(width: 350, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary)
                .shadow(radius: 3)
        )
        .onChange(of: level) { oldValue, newValue in
            onLevelChange?(newValue)
        }
    }
}

struct ActivitySliderView_Previews: PreviewProvider {
    @State static private var previewLevel: ActivityLevel = .sedentary

    static var previews: some View {
        Group {
            ActivitySliderView(level: $previewLevel) { newLevel in
                print("Selected level: \(newLevel)")
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.light)

            ActivitySliderView(level: $previewLevel)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
*/
