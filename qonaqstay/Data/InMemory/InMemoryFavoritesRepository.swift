import Foundation

actor InMemoryFavoritesRepository: FavoritesRepository {
    // userId -> Set<hostPlaceId>
    private var favoritesByUserId: [String: Set<String>] = [:]
    
    func addFavorite(userId: String, hostPlaceId: String) async throws {
        favoritesByUserId[userId, default: []].insert(hostPlaceId)
    }
    
    func removeFavorite(userId: String, hostPlaceId: String) async throws {
        favoritesByUserId[userId]?.remove(hostPlaceId)
    }
    
    func isFavorite(userId: String, hostPlaceId: String) async throws -> Bool {
        favoritesByUserId[userId]?.contains(hostPlaceId) ?? false
    }
    
    func listFavorites(userId: String) async throws -> [String] {
        Array(favoritesByUserId[userId] ?? [])
    }
}

