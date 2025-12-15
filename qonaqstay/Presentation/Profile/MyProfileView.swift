import SwiftUI

struct MyProfileView: View {
    let userId: String

    @Environment(\.container) private var container
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm = MyProfileViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("profile.main") {
                    TextField("profile.name", text: $vm.name)
                    TextField("profile.city", text: $vm.city)
                    TextField("profile.about", text: $vm.about, axis: .vertical)
                }

                Section("profile.language") {
                    Picker("profile.language", selection: $vm.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.title).tag(lang)
                        }
                    }
                }

                Section("profile.roles") {
                    Toggle("profile.roleGuest", isOn: $vm.isGuest)
                    Toggle("profile.roleHost", isOn: $vm.isHost)
                }

                Section("profile.rating") {
                    LabeledContent("profile.ratingValue", value: String(format: "%.1f", vm.rating))
                }

                if let error = vm.errorText {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }

                Section {
                    Button("profile.save") {
                        Task { await vm.save(users: container.userRepository) }
                    }
                    .disabled(vm.isLoading)

                    Button("profile.signOut", role: .destructive) {
                        Task { await session.signOut() }
                    }
                }
            }
            .navigationTitle("profile.title")
            .task {
                await vm.load(userId: userId, users: container.userRepository)
            }
        }
    }
}



