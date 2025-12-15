import Foundation

actor InMemoryHostRepository: HostRepository {
    private let userRepository: UserRepository
    private var placesById: [String: HostPlace] = [:]
    private var seeded = false

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    private func seedIfNeeded() async {
        guard !seeded else { return }
        seeded = true

        // Ensure demo users exist.
        await userRepository.seedIfNeeded()

        let p1 = HostPlace(id: "hp_1", userId: "u_host_1", city: "Шымкент", placesCount: 2, rules: "Без курения")
        let p2 = HostPlace(id: "hp_2", userId: "u_host_2", city: "Шымкент", placesCount: 1, rules: "Без животных")
        let p3 = HostPlace(id: "hp_3", userId: "u_host_3", city: "Астана", placesCount: 2, rules: "Тихо после 23:00")

        placesById[p1.id] = p1
        placesById[p2.id] = p2
        placesById[p3.id] = p3
    }

    func listHosts(city: String?) async throws -> [HostPlace] {
        await seedIfNeeded()
        let all = Array(placesById.values)
        guard let city, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return all.sorted { $0.city < $1.city }
        }
        return all
            .filter { $0.city.lowercased() == city.lowercased() }
            .sorted { $0.placesCount > $1.placesCount }
    }
    
    func listHosts(filters: HostSearchFilters) async throws -> [HostPlace] {
        await seedIfNeeded()
        var all = Array(placesById.values)
        
        // Фильтр по городу
        if let city = filters.city, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            all = all.filter { $0.city.lowercased() == city.lowercased() }
        }
        
        // Фильтр по количеству мест
        if let minPlaces = filters.minPlacesCount {
            all = all.filter { $0.placesCount >= minPlaces }
        }
        if let maxPlaces = filters.maxPlacesCount {
            all = all.filter { $0.placesCount <= maxPlaces }
        }
        
        // Фильтр по правилам
        if let hasRules = filters.hasRules {
            if hasRules {
                all = all.filter { !$0.rules.isEmpty }
            } else {
                all = all.filter { $0.rules.isEmpty }
            }
        }
        
        // Фильтр по рейтингу и полу требует загрузки пользователей
        // Применяем их после получения пользователей
        return all.sorted { $0.placesCount > $1.placesCount }
    }

    func getHostPlace(id: String) async throws -> HostPlace {
        await seedIfNeeded()
        guard let place = placesById[id] else { throw AuthError.userNotFound }
        return place
    }

    func upsertHostPlace(_ place: HostPlace) async throws {
        placesById[place.id] = place
    }
}



