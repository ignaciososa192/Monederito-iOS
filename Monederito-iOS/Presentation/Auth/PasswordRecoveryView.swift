import SwiftUI

struct PasswordRecoveryView: View {
    let isUpdatingPassword: Bool
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var error: String?

    private var isValid: Bool {
        isUpdatingPassword ? password.count >= 8 && password == confirmation : email.contains("@") && email.contains(".")
    }

    var body: some View {
        NavigationStack {
            Form {
                if isUpdatingPassword {
                    SecureField("Nueva contraseña (mínimo 8 caracteres)", text: $password)
                        .textContentType(.newPassword)
                    SecureField("Repetir contraseña", text: $confirmation)
                        .textContentType(.newPassword)
                } else {
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                if let message { Text(message) }
                if let error { Text(error).foregroundStyle(.red) }
                Button(isUpdatingPassword ? "Guardar contraseña" : "Enviar enlace") {
                    Task { await submit() }
                }
                .disabled(!isValid || isLoading)
                if isLoading { ProgressView() }
            }
            .navigationTitle(isUpdatingPassword ? "Nueva contraseña" : "Recuperar cuenta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        if isUpdatingPassword {
                            Task { await appState.signOut(using: container.authRepository) }
                        } else { dismiss() }
                    }.disabled(isLoading)
                }
            }
        }
    }

    @MainActor
    private func submit() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            if isUpdatingPassword {
                try await container.authRepository.updatePassword(password)
                password = ""
                confirmation = ""
                await appState.signOut(using: container.authRepository)
            } else {
                try await container.authRepository.resetPassword(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
                message = AppConfiguration.current?.environment == .mock
                    ? "Simulación Mock: no se envía correo. Probá el enlace real en Sandbox."
                    : "Si el correo tiene una cuenta, recibirás un enlace para cambiar tu contraseña. Abrilo en este dispositivo."
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
