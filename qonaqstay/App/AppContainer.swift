import SwiftUI

/// Dependency container for the app.
///
/// In MVP we start with in-memory repositories to move fast.
/// Later you can replace implementations with Firebase-backed ones without touching UI.
final class AppContainer: ObservableObject {
    let authRepository: AuthRepository
    let userRepository: UserRepository
    let hostRepository: HostRepository
    let chatRepository: ChatRepository

    init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        hostRepository: HostRepository,
        chatRepository: ChatRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.hostRepository = hostRepository
        self.chatRepository = chatRepository
    }

    nonisolated static func liveInMemory() -> AppContainer {
        let users = InMemoryUserRepository()
        let auth = InMemoryAuthRepository(userRepository: users)
        let hosts = InMemoryHostRepository(userRepository: users)
        let chat = InMemoryChatRepository(userRepository: users)

        return AppContainer(
            authRepository: auth,
            userRepository: users,
            hostRepository: hosts,
            chatRepository: chat
        )
    }
}

private struct AppContainerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = AppContainer.liveInMemory()
}

extension EnvironmentValues {
    var container: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    func environment(_ container: AppContainer) -> some View {
        environment(\.container, container)
    }
}


