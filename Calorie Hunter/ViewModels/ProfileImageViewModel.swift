import SwiftUI
import CoreData

class ProfileImageViewModel: ObservableObject {
    @Published var profileImage: UIImage? {
        didSet {
            saveProfileImage()
        }
    }
    
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfileImage()
    }
    
    func updateImage(_ image: UIImage?) {
        profileImage = image
    }
    
    private func saveProfileImage() {
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            // If the image is nil, remove stored image data.
            if let profile = fetchUserProfile() {
                profile.profileImageData = nil
                try? context.save()
            }
            return
        }
        if let profile = fetchUserProfile() {
            profile.profileImageData = imageData
            try? context.save()
        }
    }
    
    private func loadProfileImage() {
        if let profile = fetchUserProfile(),
           let data = profile.profileImageData,
           let image = UIImage(data: data) {
            profileImage = image
        }
    }
    
    private func fetchUserProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let profiles = try context.fetch(request)
            return profiles.first
        } catch {
            print("Error fetching profile image: \(error)")
            return nil
        }
    }
}
