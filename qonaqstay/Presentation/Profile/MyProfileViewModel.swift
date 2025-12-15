import Foundation
import UIKit

@MainActor
final class MyProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var city: String = ""
    @Published var about: String = ""
    @Published var language: AppLanguage = .ru
    @Published var isGuest: Bool = true
    @Published var isHost: Bool = false
    @Published var profileImageURL: String?
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var gender: HostGender?
    @Published var selectedImage: UIImage?

    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?
    @Published private(set) var rating: Double = 0
    @Published private(set) var isEmailVerified: Bool = false
    @Published private(set) var isPhoneVerified: Bool = false

    private(set) var userId: String?

    func load(userId: String, users: UserRepository) async {
        self.userId = userId
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let u = try await users.getUser(id: userId)
            name = u.name
            city = u.city
            about = u.about
            language = u.language
            isGuest = u.isGuest
            isHost = u.isHost
            rating = u.rating
            profileImageURL = u.profileImageURL
            email = u.email ?? ""
            phoneNumber = u.phoneNumber ?? ""
            gender = u.gender
            isEmailVerified = u.isEmailVerified
            isPhoneVerified = u.isPhoneVerified
        } catch {
            errorText = error.localizedDescription
        }
    }

    func save(users: UserRepository) async {
        guard let userId else { return }
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let current = try await users.getUser(id: userId)
            
            // В реальном приложении здесь была бы загрузка изображения в Storage
            // Пока оставляем как есть или используем placeholder URL
            var imageURL = current.profileImageURL
            if selectedImage != nil {
                // TODO: Загрузить в Firebase Storage и получить URL
                // imageURL = try await uploadImage(selectedImage)
            }
            
            let updated = AppUser(
                id: current.id,
                name: name,
                city: city,
                about: about,
                language: language,
                isGuest: isGuest,
                isHost: isHost,
                rating: current.rating,
                profileImageURL: imageURL,
                isEmailVerified: current.isEmailVerified,
                isPhoneVerified: current.isPhoneVerified,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                email: email.isEmpty ? nil : email,
                gender: gender
            )
            try await users.upsertUser(updated)
        } catch {
            errorText = error.localizedDescription
        }
    }
}



