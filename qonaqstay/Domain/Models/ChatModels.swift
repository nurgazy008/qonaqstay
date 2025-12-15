import Foundation

struct ChatThread: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let userAId: String
    let userBId: String
    var lastMessageText: String?
    var lastMessageAt: Date?

    func otherUserId(currentUserId: String) -> String {
        currentUserId == userAId ? userBId : userAId
    }
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let threadId: String
    let fromUserId: String
    let toUserId: String
    let text: String
    let sentAt: Date
}


