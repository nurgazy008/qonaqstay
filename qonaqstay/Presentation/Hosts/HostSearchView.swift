import SwiftUI

struct HostSearchView: View {
    let userId: String

    @Environment(\.container) private var container
    @StateObject private var vm = HostSearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("hosts.cityPlaceholder", text: $vm.city)
                        .textFieldStyle(.roundedBorder)

                    Button("hosts.search") {
                        Task { await vm.load(hosts: container.hostRepository, users: container.userRepository) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 24)
                } else if let error = vm.errorText {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.top, 24)
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
            .navigationTitle("hosts.title")
            .task {
                await vm.load(hosts: container.hostRepository, users: container.userRepository)
            }
        }
    }
}

private struct HostRow: View {
    let item: HostSearchItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.user.name.isEmpty ? "hosts.noName" : item.user.name)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f", item.user.rating))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("\(item.place.city) • \(item.place.placesCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !item.place.rules.isEmpty {
                Text(item.place.rules)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}


