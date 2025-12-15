import Foundation

protocol HostRepository {
    func listHosts(city: String?) async throws -> [HostPlace]
    func getHostPlace(id: String) async throws -> HostPlace
    func upsertHostPlace(_ place: HostPlace) async throws
}



