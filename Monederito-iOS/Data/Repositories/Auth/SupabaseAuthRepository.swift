//
//  SupabaseAuthRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation
import Supabase

final class SupabaseAuthRepository: AuthRepositoryProtocol {

    private let client: SupabaseClient
    private let googleSignIn: @MainActor () async throws -> GoogleSignInResult
    private let securityService: SecurityServiceProtocol
    
    init(
        client: SupabaseClient? = SupabaseConfig.client,
        securityService: SecurityServiceProtocol = SecurityService(),
        googleSignIn: @escaping @MainActor () async throws -> GoogleSignInResult = { try await GoogleSignInManager.shared.signInWithGoogle() }
    ) {
        guard let client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
        self.googleSignIn = googleSignIn
        self.client = client
        self.securityService = securityService
    }
    
    // MARK: - Email/Password
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            return try await fetchProfile(for: session.user)
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Google Sign In
    // CONCEPTO: El flujo es:
    // 1. Google SDK autentica al usuario y nos da un idToken
    // 2. Pasamos ese idToken a Supabase
    // 3. Supabase verifica el token con Google y crea/recupera la sesión
    // 4. Nosotros buscamos o creamos el perfil en nuestra tabla profiles
    func signInWithGoogle(role: UserRole? = nil) async throws -> User {
        // Paso 1: Login con Google
        let googleResult = try await googleSignIn()

        // Paso 2: Autenticar en Supabase con el idToken de Google
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: googleResult.idToken,
                    accessToken: googleResult.accessToken
                )
            )

            return try await fetchProfile(for: session.user)
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> SignUpResult {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": AnyJSON.string(fullName),
                    "role":      AnyJSON.string(role.rawValue),
                    "phone":     AnyJSON.string(phone)
                ],
                redirectTo: URL(string: "monederito://auth/callback")
            )
            
            guard let session = response.session else {
                return .confirmationRequired(email: email)
            }
            let authUser = session.user
            
            // El trigger de Supabase crea el perfil automáticamente
            // Usamos retry logic con exponential backoff para esperar el trigger
            return .authenticated(try await fetchProfileWithRetry(for: authUser))
        } catch let error as AppError {
            throw error
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Session Management
    
    func signOut() async throws {
        GoogleSignInManager.shared.signOut()
        try await client.auth.signOut(scope: .local)
    }
    
    func getCurrentUser() async throws -> User? {
        do {
            let session = try await client.auth.session
            return try await fetchProfile(for: session.user)
        } catch AuthError.sessionMissing {
            return nil
        } catch AuthError.api(_, let code, _, _) where code == .refreshTokenNotFound || code == .refreshTokenAlreadyUsed {
            try? await client.auth.signOut(scope: .local)
            return nil
        } catch {
            throw mapSupabaseError(error)
        }
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email, redirectTo: URL(string: "monederito://auth/recovery"))
    }

    func updatePassword(_ password: String) async throws {
        _ = try await client.auth.update(user: UserAttributes(password: password))
    }

    func handleAuthCallback(_ url: URL) async throws {
        _ = try await client.auth.session(from: url)
    }

    func sessionEvents() -> AsyncStream<AuthSessionEvent> {
        AsyncStream { continuation in
            let task = Task {
                for await change in client.auth.authStateChanges {
                    switch change.event {
                    case .signedOut: continuation.yield(.signedOut)
                    case .passwordRecovery: continuation.yield(.passwordRecovery)
                    default: break
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func updateProfile(_ user: User) async throws -> User {
        try await client
            .from(SupabaseConfig.Tables.profiles)
            .update([
                "full_name": user.fullName,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: user.id.uuidString)
            .execute()
        return user
    }
    
    func enableBiometrics() async throws {
        guard securityService.isBiometricAvailable() else {
            throw AppError.biometricNotAvailable
        }
        
        // Test biometric authentication
        let success = try await securityService.authenticate()
        guard success else {
            throw AppError.authenticationFailed
        }
        
        // Save a flag to keychain indicating biometrics is enabled
        try securityService.saveCredential("enabled", forKey: "biometric_enabled")
    }
    
    // MARK: - Helpers privados
    
    // The existing auth.users trigger owns profile creation, including Google users.
    // Retry only a missing row; propagate network/decoding/permission errors unchanged.
    private func fetchProfileWithRetry(for authUser: Supabase.User) async throws -> User {
        for attempt in 0..<5 {
            do {
                return try await fetchProfile(for: authUser)
            } catch AppError.profileCreationFailed where attempt < 4 {
                try await Task.sleep(nanoseconds: UInt64(1 << attempt) * 100_000_000)
            }
        }
        throw AppError.profileCreationFailed
    }

    private func fetchProfile(for authUser: Supabase.User) async throws -> User {
        let response = try await client
            .from(SupabaseConfig.Tables.profiles)
            .select()
            .eq("id", value: authUser.id.uuidString)
            .execute()
        let profiles = try JSONDecoder().decode([SupabaseProfile].self, from: response.data)
        guard profiles.count == 1, let profile = profiles.first else { throw AppError.profileCreationFailed }
        return profile.toUser()
    }

    // Mapear errores de Supabase a AppError
    private func mapSupabaseError(_ error: Error) -> AppError {
        if let error = error as? AppError { return error }
        if error is URLError { return .networkUnavailable }
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid") || message.contains("credentials") {
            return .invalidCredentials
        }
        if message.contains("already registered") || message.contains("already exists") {
            return .emailAlreadyInUse
        }
        if message.contains("network") || message.contains("connection") {
            return .networkUnavailable
        }
        return .serverError(code: 0, message: error.localizedDescription)
    }
}

// MARK: - DTO para decodificar la respuesta de Supabase

// CONCEPTO: DTO (Data Transfer Object)
// Es la representación de los datos TAL COMO vienen de la API.
// Lo separamos del modelo de dominio (User) para que los cambios
// en el backend no afecten al resto de la app.

struct SupabaseProfile: Codable {
    let id: String
    let fullName: String
    let email: String
    let role: String
    let phone: String?
    let benefactorId: String?
    let monthlyLimit: Double?
    let dailyLimit: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName       = "full_name"
        case email
        case role
        case phone
        case benefactorId   = "benefactor_id"
        case monthlyLimit   = "monthly_limit"
        case dailyLimit     = "daily_limit"
    }
    
    // Convertir DTO → Modelo de dominio
    func toUser() -> User {
        User(
            id: UUID(uuidString: id) ?? UUID(),
            fullName: fullName,
            email: email,
            role: UserRole(rawValue: role) ?? .benefactor,
            benefactorID: benefactorId.flatMap { UUID(uuidString: $0) },
            monthlyLimit: monthlyLimit,
            dailyLimit: dailyLimit
        )
    }
}

