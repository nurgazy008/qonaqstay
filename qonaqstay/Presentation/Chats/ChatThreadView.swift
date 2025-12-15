import SwiftUI

struct ChatThreadView: View {
    let currentUserId: String
    let thread: ChatThread

    @Environment(\.container) private var container
    @StateObject private var vm = ChatThreadViewModel()
    @State private var otherUser: AppUser?

    private var otherUserId: String {
        thread.otherUserId(currentUserId: currentUserId)
    }

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView().padding(.top, 24)
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.messages) { message in
                                MessageBubble(
                                    text: message.text,
                                    isMine: message.fromUserId == currentUserId
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        if let last = vm.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }

            if let error = vm.errorText {
                Text(error)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .padding(.bottom, 6)
            }

            Divider()

            HStack(spacing: 10) {
                TextField("chat.messagePlaceholder", text: $vm.draftText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                Button("chat.send") {
                    Task {
                        await vm.send(
                            thread: thread,
                            fromUserId: currentUserId,
                            toUserId: otherUserId,
                            chat: container.chatRepository
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle(otherUser?.name.isEmpty == false ? otherUser!.name : String(localized: "chat.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load(threadId: thread.id, chat: container.chatRepository)
            otherUser = try? await container.userRepository.getUser(id: otherUserId)
        }
    }
}

private struct MessageBubble: View {
    let text: String
    let isMine: Bool

    var body: some View {
        HStack {
            if isMine { Spacer(minLength: 40) }
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isMine ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !isMine { Spacer(minLength: 40) }
        }
    }
}


