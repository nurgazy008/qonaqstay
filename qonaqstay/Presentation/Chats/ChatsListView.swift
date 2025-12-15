import SwiftUI

struct ChatsListView: View {
    let userId: String

    @Environment(\.container) private var container
    @StateObject private var vm = ChatsListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView().padding(.top, 24)
                } else if let error = vm.errorText {
                    Text(error).foregroundStyle(.red).padding(.top, 24)
                } else if vm.items.isEmpty {
                    ContentUnavailableView("chats.emptyTitle", systemImage: "message", description: Text("chats.emptySubtitle"))
                } else {
                    List(vm.items) { item in
                        NavigationLink {
                            ChatThreadView(currentUserId: userId, thread: item.thread)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.otherUser.name.isEmpty ? "hosts.noName" : item.otherUser.name)
                                    .font(.headline)
                                Text(item.thread.lastMessageText ?? "chats.noMessagesYet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("chats.title")
            .toolbar {
                Button {
                    Task {
                        await vm.load(
                            currentUserId: userId,
                            chat: container.chatRepository,
                            users: container.userRepository
                        )
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await vm.load(currentUserId: userId, chat: container.chatRepository, users: container.userRepository)
            }
        }
    }
}



