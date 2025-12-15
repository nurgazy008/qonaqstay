import Foundation

actor InMemoryChatRepository: ChatRepository {
    private let userRepository: UserRepository

    private var threadsById: [String: ChatThread] = [:]
    private var messagesByThreadId: [String: [ChatMessage]] = [:]

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func listThreads(for userId: String) async throws -> [ChatThread] {
        // Ensure demo users exist (so chat list can show names).
        await userRepository.seedIfNeeded()

        return threadsById.values
            .filter { $0.userAId == userId || $0.userBId == userId }
            .sorted { ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast) }
    }

    func getOrCreateThread(userAId: String, userBId: String) async throws -> ChatThread {
        await userRepository.seedIfNeeded()

        if let existing = threadsById.values.first(where: {
            ($0.userAId == userAId && $0.userBId == userBId) ||
            ($0.userAId == userBId && $0.userBId == userAId)
        }) {
            return existing
        }

        let id = "t_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let thread = ChatThread(id: id, userAId: userAId, userBId: userBId, lastMessageText: nil, lastMessageAt: nil)
        threadsById[id] = thread
        messagesByThreadId[id] = []
        return thread
    }

    func listMessages(threadId: String) async throws -> [ChatMessage] {
        messagesByThreadId[threadId, default: []]
            .sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage(threadId: String, fromUserId: String, toUserId: String, text: String) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let message = ChatMessage(
            id: "m_" + UUID().uuidString.replacingOccurrences(of: "-", with: ""),
            threadId: threadId,
            fromUserId: fromUserId,
            toUserId: toUserId,
            text: trimmed,
            sentAt: Date()
        )

        messagesByThreadId[threadId, default: []].append(message)

        var thread = threadsById[threadId] ?? ChatThread(
            id: threadId,
            userAId: fromUserId,
            userBId: toUserId,
            lastMessageText: nil,
            lastMessageAt: nil
        )
        thread.lastMessageText = trimmed
        thread.lastMessageAt = message.sentAt
        threadsById[threadId] = thread
    }
}



