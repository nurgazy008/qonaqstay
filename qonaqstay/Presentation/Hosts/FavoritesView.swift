import SwiftUI

struct FavoritesView: View {
    let userId: String
    
    @Environment(\.container) private var container
    @StateObject private var vm = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 24)
                } else if let error = vm.errorText {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.top, 24)
                } else if vm.items.isEmpty {
                    EmptyStateView(
                        title: "Нет избранных хостов",
                        message: "Добавляйте хостов в избранное, чтобы вернуться к ним позже"
                    )
                } else {
                    List(vm.items) { item in
                        NavigationLink {
                            HostProfileView(currentUserId: userId, item: item)
                        } label: {
                            HostRow(item: item)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Избранное")
            .task {
                await vm.load(userId: userId, container: container)
            }
            .refreshable {
                await vm.load(userId: userId, container: container)
            }
        }
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var items: [HostSearchItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorText: String?
    
    func load(userId: String, container: AppContainer) async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }
        
        do {
            let favoritePlaceIds = try await container.favoritesRepository.listFavorites(userId: userId)
            var result: [HostSearchItem] = []
            
            for placeId in favoritePlaceIds {
                do {
                    let place = try await container.hostRepository.getHostPlace(id: placeId)
                    let user = try await container.userRepository.getUser(id: place.userId)
                    result.append(HostSearchItem(place: place, user: user))
                } catch {
                    // Пропускаем если место или пользователь не найдены
                    continue
                }
            }
            
            items = result
        } catch {
            errorText = error.localizedDescription
            items = []
        }
    }
}

