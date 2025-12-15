import SwiftUI

struct HostProfileView: View {
    let currentUserId: String
    let item: HostSearchItem

    @Environment(\.container) private var container
    @State private var isStartingChat = false
    @State private var errorText: String?
    @State private var thread: ChatThread?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.user.name.isEmpty ? "hosts.noName" : item.user.name)
                        .font(.title2.bold())

                    Text(item.user.city)
                        .foregroundStyle(.secondary)

                    if !item.user.about.isEmpty {
                        Text(item.user.about)
                            .padding(.top, 4)
                    }

                    HStack {
                        Label(String(format: "%.1f", item.user.rating), systemImage: "star.fill")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.user.language.title)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 6)
                }
                .padding(.vertical, 4)
            }

            Section("hosts.placeInfo") {
                LabeledContent("hosts.city", value: item.place.city)
                LabeledContent("hosts.placesCount", value: "\(item.place.placesCount)")
                LabeledContent("hosts.rules", value: item.place.rules.isEmpty ? "—" : item.place.rules)
            }

            if let errorText {
                Section {
                    Text(errorText).foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    startChat()
                } label: {
                    if isStartingChat {
                        ProgressView()
                    } else {
                        Text("hosts.writeMessage")
                    }
                }
                .disabled(isStartingChat || currentUserId == item.user.id)
            }
        }
        .navigationTitle("hosts.profileTitle")
        .navigationDestination(item: $thread) { thread in
            ChatThreadView(currentUserId: currentUserId, thread: thread)
        }
    }

    private func startChat() {
        errorText = nil
        isStartingChat = true

        Task {
            do {
                let t = try await container.chatRepository.getOrCreateThread(
                    userAId: currentUserId,
                    userBId: item.user.id
                )
                thread = t
            } catch {
                errorText = error.localizedDescription
            }
            isStartingChat = false
        }
    }
}



