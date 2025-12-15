import Foundation

actor InMemoryUserRepository: UserRepository {
    private var usersById: [String: AppUser] = [:]
    private var seeded = false

    func seedIfNeeded() async {
        guard !seeded else { return }
        seeded = true

        // Demo users (hosts) to make MVP testable immediately.
        let host1 = AppUser(
            id: "u_host_1",
            name: "Айбек",
            city: "Шымкент",
            about: "Принимаю гостей, люблю путешествия по Казахстану.",
            language: .ru,
            isGuest: true,
            isHost: true,
            rating: 4.8
        )

        let host2 = AppUser(
            id: "u_host_2",
            name: "Алия",
            city: "Шымкент",
            about: "Могу принять на 1-2 ночи, без животных.",
            language: .kz,
            isGuest: true,
            isHost: true,
            rating: 4.6
        )

        let host3 = AppUser(
            id: "u_host_3",
            name: "Данияр",
            city: "Астана",
            about: "Уютная квартира рядом с центром.",
            language: .ru,
            isGuest: true,
            isHost: true,
            rating: 4.9
        )

        usersById[host1.id] = host1
        usersById[host2.id] = host2
        usersById[host3.id] = host3
    }

    func getUser(id: String) async throws -> AppUser {
        if let user = usersById[id] { return user }
        throw AuthError.userNotFound
    }

    func upsertUser(_ user: AppUser) async throws {
        usersById[user.id] = user
    }
}



