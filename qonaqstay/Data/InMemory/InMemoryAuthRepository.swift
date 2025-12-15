import Foundation

actor InMemoryAuthRepository: AuthRepository {
    private let userRepository: UserRepository
    private var credentialsByEmail: [String: (userId: String, password: String)] = [:]
    nonisolated(unsafe) private var _currentUserId: String?

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    nonisolated(unsafe) var currentUserId: String? { _currentUserId }

    func signIn(email: String, password: String) async throws -> String {
        let key = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let entry = credentialsByEmail[key] else {
            throw AuthError.userNotFound
        }
        guard entry.password == password else {
            throw AuthError.invalidCredentials
        }

        _currentUserId = entry.userId
        return entry.userId
    }

    func register(email: String, password: String) async throws -> String {
        let key = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard password.count >= 6 else { throw AuthError.passwordTooShort }
        guard credentialsByEmail[key] == nil else { throw AuthError.emailAlreadyInUse }

        let newId = "u_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        credentialsByEmail[key] = (userId: newId, password: password)
        _currentUserId = newId

        let newUser = AppUser(
            id: newId,
            name: "",
            city: "",
            about: "",
            language: .ru,
            isGuest: true,
            isHost: false,
            rating: 0
        )
        try await userRepository.upsertUser(newUser)
        return newId
    }

    func signOut() async {
        _currentUserId = nil
    }
}


