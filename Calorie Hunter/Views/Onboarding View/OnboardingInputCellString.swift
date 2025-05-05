import SwiftUI

/// A reusable input cell designed for onboarding screens that accepts a string value.
/// The cell displays an optional system image, a title, and a centered text field with a placeholder.
struct OnboardingInputCellString: View {
    // MARK: - Input Properties
    
    /// The title displayed above the input field.
    var title: String
    
    /// The placeholder text shown in the text field when no value is present.
    var placeholder: String = ""
    
    /// An optional system image name to be displayed above the title.
    var systemImageName: String? = nil
    
    /// A binding to the string value entered by the user.
    @Binding var value: String
    
    // Local text state for editing
    @State private var text: String = ""
    
    /// Commit the current text into the bound string value.
    private func commit() {
        value = text
    }
    
    // MARK: - Environment & Focus State
    
    /// Access the current color scheme (light or dark) for dynamic styling.
    @Environment(\.colorScheme) var colorScheme
    
    /// Manages the focus state of the text field.
    @FocusState private var isFocused: Bool

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 4) {
            // Optionally display a system image if provided.
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    // Adjust image color based on the current color scheme.
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.top, 10)
            }
            
            // Display the title above the text field.
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            // A TextField bound to the local text state with commit handling.
            TextField(placeholder, text: $text, onEditingChanged: { began in
                if !began {
                    commit()
                }
            })
            .submitLabel(.done)
            .onSubmit { commit() }
            .tint(Color.blue) // Set the cursor and accent color.
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            // Text color changes based on the current color scheme.
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .focused($isFocused)
            .frame(height: 30)
            .onAppear {
                // Initialize the text field from the bound string value
                text = value
            }
            .onChange(of: value) {
                text = value
            }
        }
        .frame(width: 180, height: 100) // Define a fixed overall size for the cell.
        .background(
            // Background with rounded corners and a subtle shadow.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .shadow(radius: 3)
        )
        // Tapping anywhere in the cell sets focus to the text field.
        .onTapGesture {
            isFocused = true
        }
    }
}
