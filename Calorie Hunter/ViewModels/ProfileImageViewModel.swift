import SwiftUI
import CoreData

// ProfileImageViewModel manages the user's profile image by loading and saving it to Core Data.
// It also publishes changes to the profile image so that any SwiftUI views can react accordingly.
class ProfileImageViewModel: ObservableObject {
    // The currently selected profile image.
    // Whenever this property changes, the new image is automatically saved.
    @Published var profileImage: UIImage? {
        didSet {
            saveProfileImage()
        }
    }
    
    // Core Data context used to fetch and update the user profile.
    private var context: NSManagedObjectContext
    
    // Initializes the view model with a Core Data context.
    // It loads the stored profile image (if any) upon initialization.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfileImage()
    }
    
    /// Updates the profile image with a new image.
    /// - Parameter image: The new UIImage to set as the profile image.
    func updateImage(_ image: UIImage?) {
        profileImage = image
    }
    
    /// Saves the current profile image to Core Data.
    /// If there is no image (i.e. it's nil), it removes any stored image data.
    private func saveProfileImage() {
        // Check if we have an image and convert it to JPEG data with 80% quality.
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            // If the image is nil, remove the stored image data from the user's profile.
            if let profile = fetchUserProfile() {
                profile.profileImageData = nil
                try? context.save()
            }
            return
        }
        // If an image exists, fetch the user's profile and update its profileImageData.
        if let profile = fetchUserProfile() {
            profile.profileImageData = imageData
            try? context.save()
        }
    }
    
    /// Loads the profile image from Core Data and sets the published property.
    private func loadProfileImage() {
        // Fetch the user profile from Core Data.
        if let profile = fetchUserProfile(),
           let data = profile.profileImageData,
           let image = UIImage(data: data) {
            // Set the loaded image as the current profile image.
            profileImage = image
        }
    }
    
    /// Fetches the UserProfile object from Core Data.
    ///
    /// - Returns: The first UserProfile found, or nil if there is an error.
    private func fetchUserProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            // Try to fetch the user profiles from the context.
            let profiles = try context.fetch(request)
            // Return the first profile (assuming a single profile for the user).
            return profiles.first
        } catch {
            print("Error fetching profile image: \(error)")
            return nil
        }
    }
}
