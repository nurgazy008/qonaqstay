import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var city: String
    var about: String
    var language: AppLanguage
    var isGuest: Bool
    var isHost: Bool
    var rating: Double
}



