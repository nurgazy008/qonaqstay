import Foundation

@MainActor
final class HostSearchViewModel: ObservableObject {
    @Published var city: String = "Шымкент"
    @Published private(set) var items: [HostSearchItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?
    
    // Фильтры
    @Published var showFilters = false
    @Published var minPlacesCount: Int?
    @Published var maxPlacesCount: Int?
    @Published var minRating: Double?
    @Published var selectedGender: HostGender?
    @Published var hasRules: Bool?
    
    var activeFiltersCount: Int {
        var count = 0
        if minPlacesCount != nil { count += 1 }
        if maxPlacesCount != nil { count += 1 }
        if minRating != nil { count += 1 }
        if selectedGender != nil { count += 1 }
        if hasRules != nil { count += 1 }
        return count
    }

    func load(hosts: HostRepository, users: UserRepository) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let filters = HostSearchFilters(
                city: city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : city.trimmingCharacters(in: .whitespacesAndNewlines),
                minPlacesCount: minPlacesCount,
                maxPlacesCount: maxPlacesCount,
                minRating: minRating,
                gender: selectedGender,
                hasRules: hasRules
            )
            
            let places = try await hosts.listHosts(filters: filters)
            var result: [HostSearchItem] = []
            result.reserveCapacity(places.count)

            for place in places {
                let user = try await users.getUser(id: place.userId)
                
                // Применяем фильтры по рейтингу и полу
                if let minRating = minRating, user.rating < minRating {
                    continue
                }
                if let gender = selectedGender, user.gender != gender {
                    continue
                }
                
                result.append(HostSearchItem(place: place, user: user))
            }

            items = result
        } catch {
            errorText = error.localizedDescription
            items = []
        }
    }
    
    func clearFilters() {
        minPlacesCount = nil
        maxPlacesCount = nil
        minRating = nil
        selectedGender = nil
        hasRules = nil
    }
}

struct HostSearchItem: Identifiable, Equatable {
    let place: HostPlace
    let user: AppUser
    var id: String { place.id }
}


