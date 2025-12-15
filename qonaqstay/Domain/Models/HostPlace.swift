import Foundation

struct HostPlace: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    var city: String
    var placesCount: Int
    var rules: String
}



