import Foundation

@MainActor
final class ChatsListViewModel: ObservableObject {
    @Published private(set) var items: [ChatsListItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?

    func load(currentUserId: String, chat: ChatRepository, users: UserRepository) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let threads = try await chat.listThreads(for: currentUserId)
            var result: [ChatsListItem] = []
            result.reserveCapacity(threads.count)

            for t in threads {
                let otherId = t.otherUserId(currentUserId: currentUserId)
                let otherUser = try await users.getUser(id: otherId)
                result.append(ChatsListItem(thread: t, otherUser: otherUser))
            }

            items = result
        } catch {
            errorText = error.localizedDescription
            items = []
        }
    }
}

struct ChatsListItem: Identifiable, Equatable {
    let thread: ChatThread
    let otherUser: AppUser
    var id: String { thread.id }
}



