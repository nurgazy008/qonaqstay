import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case ru
    case kz

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ru: return "RU"
        case .kz: return "KZ"
        }
    }
}



