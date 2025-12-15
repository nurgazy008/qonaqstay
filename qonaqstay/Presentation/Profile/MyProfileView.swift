import SwiftUI
import PhotosUI

struct MyProfileView: View {
    let userId: String

    @Environment(\.container) private var container
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm = MyProfileViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ProfileImageView(imageURL: vm.profileImageURL, selectedImage: vm.selectedImage)
                            .onTapGesture {
                                // Открыть выбор фото
                            }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Загрузить фото", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    vm.selectedImage = uiImage
                                }
                            }
                        }
                    }
                }
                
                Section("profile.main") {
                    TextField("profile.name", text: $vm.name)
                    TextField("profile.city", text: $vm.city)
                    TextField("profile.about", text: $vm.about, axis: .vertical)
                }
                
                Section("Контактная информация") {
                    HStack {
                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        if vm.isEmailVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    HStack {
                        TextField("Телефон", text: $vm.phoneNumber)
                            .keyboardType(.phonePad)
                        if vm.isPhoneVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    if !vm.isEmailVerified || !vm.isPhoneVerified {
                        Text("Подтвердите email или телефон для получения бейджа проверен")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("profile.language") {
                    Picker("profile.language", selection: $vm.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.title).tag(lang)
                        }
                    }
                }
                
                Section("Дополнительно") {
                    Picker("Пол", selection: $vm.gender) {
                        Text("Не указан").tag(HostGender?.none)
                        ForEach(HostGender.allCases) { gender in
                            Text(gender.displayName).tag(HostGender?.some(gender))
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

private struct ProfileImageView: View {
    let imageURL: String?
    let selectedImage: UIImage?
    
    var body: some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
    }
}



