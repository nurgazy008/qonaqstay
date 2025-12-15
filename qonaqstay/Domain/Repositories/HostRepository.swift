import Foundation

struct HostSearchFilters {
    var city: String?
    var minPlacesCount: Int?
    var maxPlacesCount: Int?
    var minRating: Double?
    var gender: HostGender?
    var hasRules: Bool?
}

protocol HostRepository {
    func listHosts(city: String?) async throws -> [HostPlace]
    func listHosts(filters: HostSearchFilters) async throws -> [HostPlace]
    func getHostPlace(id: String) async throws -> HostPlace
    func upsertHostPlace(_ place: HostPlace) async throws
}



