import Foundation

@MainActor
final class ChatThreadViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var draftText: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?

    func load(threadId: String, chat: ChatRepository) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            messages = try await chat.listMessages(threadId: threadId)
        } catch {
            errorText = error.localizedDescription
        }
    }

    func send(thread: ChatThread, fromUserId: String, toUserId: String, chat: ChatRepository) async {
        let text = draftText
        draftText = ""
        do {
            try await chat.sendMessage(threadId: thread.id, fromUserId: fromUserId, toUserId: toUserId, text: text)
            messages = try await chat.listMessages(threadId: thread.id)
        } catch {
            errorText = error.localizedDescription
        }
    }
}



