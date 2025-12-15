import Foundation

protocol ChatRepository {
    func listThreads(for userId: String) async throws -> [ChatThread]
    func getOrCreateThread(userAId: String, userBId: String) async throws -> ChatThread
    func listMessages(threadId: String) async throws -> [ChatMessage]
    func sendMessage(threadId: String, fromUserId: String, toUserId: String, text: String) async throws
}



