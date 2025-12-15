import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var userId: String?

    private let auth: AuthRepository
    private let users: UserRepository

    init(auth: AuthRepository, users: UserRepository) {
        self.auth = auth
        self.users = users
        self.userId = auth.currentUserId
    }

    func seed() async {
        await users.seedIfNeeded()
    }

    func signIn(email: String, password: String) async throws {
        let id = try await auth.signIn(email: email, password: password)
        userId = id
    }

    func register(email: String, password: String) async throws {
        let id = try await auth.register(email: email, password: password)
        userId = id
    }

    func signOut() async {
        await auth.signOut()
        userId = nil
    }
}



