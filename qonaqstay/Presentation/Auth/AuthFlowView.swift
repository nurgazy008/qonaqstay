import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var mode: Mode = .signIn

    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    @State private var isLoading = false

    enum Mode: String, CaseIterable, Identifiable {
        case signIn
        case register
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("auth.mode", selection: $mode) {
                    Text("auth.signIn").tag(Mode.signIn)
                    Text("auth.register").tag(Mode.register)
                }
                .pickerStyle(.segmented)

                Section("auth.emailSection") {
                    TextField("auth.email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }

                Section("auth.passwordSection") {
                    SecureField("auth.password", text: $password)
                }

                if let errorText {
                    Section {
                        Text(errorText)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text(mode == .signIn ? "auth.signIn" : "auth.register")
                        }
                    }
                    .disabled(isLoading)

                    Button("auth.phoneSoon") {}
                        .disabled(true)
                }
            }
            .navigationTitle("app.title")
        }
    }

    private func submit() {
        errorText = nil
        isLoading = true

        Task {
            do {
                switch mode {
                case .signIn:
                    try await session.signIn(email: email, password: password)
                case .register:
                    try await session.register(email: email, password: password)
                }
            } catch {
                errorText = error.localizedDescription
            }
            isLoading = false
        }
    }
}



