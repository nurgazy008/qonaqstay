import Foundation

@MainActor
final class MyProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var city: String = ""
    @Published var about: String = ""
    @Published var language: AppLanguage = .ru
    @Published var isGuest: Bool = true
    @Published var isHost: Bool = false

    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?
    @Published private(set) var rating: Double = 0

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
            let updated = AppUser(
                id: current.id,
                name: name,
                city: city,
                about: about,
                language: language,
                isGuest: isGuest,
                isHost: isHost,
                rating: current.rating
            )
            try await users.upsertUser(updated)
        } catch {
            errorText = error.localizedDescription
        }
    }
}



