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
    
    // Фото профиля
    var profileImageURL: String?
    
    // Верификация
    var isEmailVerified: Bool = false
    var isPhoneVerified: Bool = false
    var phoneNumber: String?
    var email: String?
    
    // Пол хоста (для фильтров)
    var gender: HostGender?
    
    var isVerified: Bool {
        isEmailVerified || isPhoneVerified
    }
}

enum HostGender: String, Codable, CaseIterable, Identifiable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .male: return "Мужской"
        case .female: return "Женский"
        case .other: return "Другой"
        }
    }
}



