import SwiftUI

struct HostProfileView: View {
    let currentUserId: String
    let item: HostSearchItem

    @Environment(\.container) private var container
    @State private var isStartingChat = false
    @State private var errorText: String?
    @State private var thread: ChatThread?
    @State private var isFavorite = false
    @State private var isTogglingFavorite = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        // Фото профиля
                        AsyncImage(url: item.user.profileImageURL.flatMap { URL(string: $0) }) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.user.name.isEmpty ? "hosts.noName" : item.user.name)
                                    .font(.title2.bold())
                                
                                if item.user.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                            
                            Text(item.user.city)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", item.user.rating))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }

                    if !item.user.about.isEmpty {
                        Text(item.user.about)
                            .padding(.top, 4)
                    }
                    
                    HStack {
                        Text(item.user.language.title)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let gender = item.user.gender {
                            Text(gender.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.vertical, 4)
            }
            
            // Фото жилья
            if !item.place.photoURLs.isEmpty {
                Section("Фото жилья") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(item.place.photoURLs, id: \.self) { urlString in
                                if let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay {
                                                ProgressView()
                                            }
                                    }
                                    .frame(width: 200, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
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
                    toggleFavorite()
                } label: {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .secondary)
                        Text(isFavorite ? "Удалить из избранного" : "Добавить в избранное")
                    }
                }
                .disabled(isTogglingFavorite)
                
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .secondary)
                }
                .disabled(isTogglingFavorite)
            }
        }
        .navigationDestination(item: $thread) { thread in
            ChatThreadView(currentUserId: currentUserId, thread: thread)
        }
        .task {
            await loadFavoriteStatus()
        }
    }
    
    private func loadFavoriteStatus() async {
        do {
            isFavorite = try await container.favoritesRepository.isFavorite(
                userId: currentUserId,
                hostPlaceId: item.place.id
            )
        } catch {
            // Игнорируем ошибку
        }
    }
    
    private func toggleFavorite() {
        isTogglingFavorite = true
        Task {
            do {
                if isFavorite {
                    try await container.favoritesRepository.removeFavorite(
                        userId: currentUserId,
                        hostPlaceId: item.place.id
                    )
                    isFavorite = false
                } else {
                    try await container.favoritesRepository.addFavorite(
                        userId: currentUserId,
                        hostPlaceId: item.place.id
                    )
                    isFavorite = true
                }
            } catch {
                errorText = error.localizedDescription
            }
            isTogglingFavorite = false
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



