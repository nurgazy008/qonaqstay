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
                    
                    Button {
                        vm.showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(vm.activeFiltersCount > 0 ? .blue : .secondary)
                            .overlay(alignment: .topTrailing) {
                                if vm.activeFiltersCount > 0 {
                                    Text("\(vm.activeFiltersCount)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(.blue, in: Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                    }
                }
                .padding(.horizontal)

                if vm.showFilters {
                    FiltersView(vm: vm)
                        .padding(.horizontal)
                }

                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 24)
                } else if let error = vm.errorText {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.top, 24)
                } else if vm.items.isEmpty {
                    EmptyStateView(
                        title: "В этом городе пока нет хостов",
                        message: "Попробуйте изменить фильтры или выбрать другой город"
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
            .navigationTitle("hosts.title")
            .task {
                await vm.load(hosts: container.hostRepository, users: container.userRepository)
            }
        }
    }
}

private struct FiltersView: View {
    @ObservedObject var vm: HostSearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Фильтры")
                    .font(.headline)
                Spacer()
                if vm.activeFiltersCount > 0 {
                    Button("Очистить") {
                        vm.clearFilters()
                    }
                    .font(.caption)
                }
            }
            
            HStack {
                Text("Мест:")
                TextField("Мин", value: $vm.minPlacesCount, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                Text("-")
                TextField("Макс", value: $vm.maxPlacesCount, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }
            
            HStack {
                Text("Рейтинг:")
                Slider(value: Binding(
                    get: { vm.minRating ?? 0 },
                    set: { vm.minRating = $0 > 0 ? $0 : nil }
                ), in: 0...5, step: 0.1)
                if let rating = vm.minRating {
                    Text(String(format: "%.1f+", rating))
                        .font(.caption)
                        .frame(width: 40)
                }
            }
            
            Picker("Пол хоста", selection: $vm.selectedGender) {
                Text("Любой").tag(HostGender?.none)
                ForEach(HostGender.allCases) { gender in
                    Text(gender.displayName).tag(HostGender?.some(gender))
                }
            }
            
            Toggle("Только с правилами", isOn: Binding(
                get: { vm.hasRules ?? false },
                set: { vm.hasRules = $0 ? true : nil }
            ))
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HostRow: View {
    let item: HostSearchItem

    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            AsyncImage(url: item.user.profileImageURL.flatMap { URL(string: $0) }) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.user.name.isEmpty ? "hosts.noName" : item.user.name)
                        .font(.headline)
                    
                    if item.user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.blue)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", item.user.rating))
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Text("\(item.place.city) • \(item.place.placesCount) мест")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !item.place.rules.isEmpty {
                    Text(item.place.rules)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


