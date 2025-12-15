import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case passwordTooShort

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid credentials"
        case .userNotFound: return "User not found"
        case .emailAlreadyInUse: return "Email already in use"
        case .passwordTooShort: return "Password too short"
        }
    }
}

protocol AuthRepository {
    nonisolated var currentUserId: String? { get }
    func signIn(email: String, password: String) async throws -> String
    func register(email: String, password: String) async throws -> String
    func signOut() async
}


