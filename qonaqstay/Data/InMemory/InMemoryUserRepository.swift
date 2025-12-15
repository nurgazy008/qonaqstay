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
            rating: 4.8,
            profileImageURL: nil,
            isEmailVerified: true,
            isPhoneVerified: true,
            phoneNumber: "+77001234567",
            email: "aibek@example.com",
            gender: .male
        )

        let host2 = AppUser(
            id: "u_host_2",
            name: "Алия",
            city: "Шымкент",
            about: "Могу принять на 1-2 ночи, без животных.",
            language: .kz,
            isGuest: true,
            isHost: true,
            rating: 4.6,
            profileImageURL: nil,
            isEmailVerified: true,
            isPhoneVerified: false,
            phoneNumber: "+77007654321",
            email: "aliya@example.com",
            gender: .female
        )

        let host3 = AppUser(
            id: "u_host_3",
            name: "Данияр",
            city: "Астана",
            about: "Уютная квартира рядом с центром.",
            language: .ru,
            isGuest: true,
            isHost: true,
            rating: 4.9,
            profileImageURL: nil,
            isEmailVerified: false,
            isPhoneVerified: true,
            phoneNumber: "+77009876543",
            email: "daniyar@example.com",
            gender: .male
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



