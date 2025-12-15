import Foundation

protocol FavoritesRepository {
    func addFavorite(userId: String, hostPlaceId: String) async throws
    func removeFavorite(userId: String, hostPlaceId: String) async throws
    func isFavorite(userId: String, hostPlaceId: String) async throws -> Bool
    func listFavorites(userId: String) async throws -> [String] // Returns hostPlaceIds
}

