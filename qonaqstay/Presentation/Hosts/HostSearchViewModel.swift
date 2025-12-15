import Foundation

@MainActor
final class HostSearchViewModel: ObservableObject {
    @Published var city: String = "Шымкент"
    @Published private(set) var items: [HostSearchItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?

    func load(hosts: HostRepository, users: UserRepository) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let places = try await hosts.listHosts(city: city.trimmingCharacters(in: .whitespacesAndNewlines))
            var result: [HostSearchItem] = []
            result.reserveCapacity(places.count)

            for place in places {
                let user = try await users.getUser(id: place.userId)
                result.append(HostSearchItem(place: place, user: user))
            }

            items = result
        } catch {
            errorText = error.localizedDescription
            items = []
        }
    }
}

struct HostSearchItem: Identifiable, Equatable {
    let place: HostPlace
    let user: AppUser
    var id: String { place.id }
}


