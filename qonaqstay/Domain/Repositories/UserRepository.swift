import Foundation

protocol UserRepository {
    func getUser(id: String) async throws -> AppUser
    func upsertUser(_ user: AppUser) async throws
    func seedIfNeeded() async
}



