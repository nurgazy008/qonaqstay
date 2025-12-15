import SwiftUI

struct AppRootView: View {
    let container: AppContainer
    @StateObject private var session: SessionStore

    init(container: AppContainer) {
        self.container = container
        _session = StateObject(wrappedValue: SessionStore(
            auth: container.authRepository,
            users: container.userRepository
        ))
    }

    var body: some View {
        Group {
            if let userId = session.userId {
                MainTabView(userId: userId)
                    .environmentObject(session)
            } else {
                AuthFlowView()
                    .environmentObject(session)
            }
        }
        .task {
            await session.seed()
        }
    }
}


