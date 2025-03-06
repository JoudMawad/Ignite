import SwiftUI

class ProfileImageViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil {
        didSet {
            saveProfileImage()
        }
    }
    
    init() {
        loadProfileImage()
    }
    
    func updateImage(_ image: UIImage?) {
        profileImage = image
        // Additional logic (e.g., upload to server) can be added here if needed.
    }
    
    private func saveProfileImage() {
        guard let image = profileImage else {
            // Remove saved data if image is nil
            UserDefaults.standard.removeObject(forKey: "profileImage")
            return
        }
        // Convert image to JPEG data with a reasonable compression quality.
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "profileImage")
        }
    }
    
    private func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: data) {
            profileImage = image
        }
    }
}
