import SwiftUI

struct MainTabView: View {
    let userId: String

    var body: some View {
        TabView {
            HostSearchView(userId: userId)
                .tabItem { Label("tab.search", systemImage: "magnifyingglass") }

            ChatsListView(userId: userId)
                .tabItem { Label("tab.chats", systemImage: "message") }

            MyProfileView(userId: userId)
                .tabItem { Label("tab.profile", systemImage: "person.crop.circle") }
        }
    }
}



