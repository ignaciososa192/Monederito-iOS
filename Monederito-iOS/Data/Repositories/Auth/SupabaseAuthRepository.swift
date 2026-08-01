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
    private let securityService: SecurityServiceProtocol
    
    init(securityService: SecurityServiceProtocol = SecurityService()) {
        guard let client = SupabaseConfig.client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
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
            return try await fetchOrCreateProfile(for: session.user)
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
        let googleResult = try await GoogleSignInManager.shared.signInWithGoogle()

        // Paso 2: Autenticar en Supabase con el idToken de Google
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: googleResult.idToken,
                    accessToken: googleResult.accessToken
                )
            )

            // Paso 3: Buscar o crear perfil en nuestra tabla
            return try await fetchOrCreateProfile(
                for: session.user,
                fullName: googleResult.fullName,
                email: googleResult.email,
                role: role ?? .benefactor
            )
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> User {
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": AnyJSON.string(fullName),
                    "role":      AnyJSON.string(role.rawValue),
                    "phone":     AnyJSON.string(phone)
                ]
            )
            
            let authUser = session.user
            
            // El trigger de Supabase crea el perfil automáticamente
            // Usamos retry logic con exponential backoff para esperar el trigger
            return try await fetchOrCreateProfileWithRetry(
                for: authUser,
                fullName: fullName,
                email: email,
                role: role,
                phone: phone
            )
        } catch let error as AppError {
            throw error
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Session Management
    
    func signOut() async throws {
        GoogleSignInManager.shared.signOut()
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        do {
            let session = try await client.auth.session
            return try await fetchOrCreateProfile(for: session.user)
        } catch {
            // Log error for debugging but return nil (no session)
            print("⚠️ Error getting current user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
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
    
    // Busca el perfil en la tabla profiles con retry logic.
    // Si no existe (primer login con Google), lo crea usando upsert para evitar race conditions.
    private func fetchOrCreateProfileWithRetry(
        for authUser: Supabase.User,
        fullName: String? = nil,
        email: String? = nil,
        role: UserRole = .benefactor,
        phone: String? = nil,
        maxRetries: Int = 5
    ) async throws -> User {
        
        for attempt in 0..<maxRetries {
            // Intentar buscar el perfil existente
            let response = try? await client
                .from(SupabaseConfig.Tables.profiles)
                .select()
                .eq("id", value: authUser.id.uuidString)
                .single()
                .execute()

            // Si existe, mapearlo
            if let data = response?.data,
               let profile = try? JSONDecoder().decode(SupabaseProfile.self, from: data) {

                // Si el rol es diferente, actualizarlo
                if UserRole(rawValue: profile.role) != role {
                    try await client
                        .from(SupabaseConfig.Tables.profiles)
                        .update(["role": role.rawValue])
                        .eq("id", value: authUser.id.uuidString)
                        .execute()

                    return User(
                        id: UUID(uuidString: profile.id) ?? UUID(),
                        fullName: fullName ?? profile.fullName,
                        email: email ?? profile.email,
                        role: role,
                        benefactorID: profile.benefactorId.flatMap { UUID(uuidString: $0) },
                        monthlyLimit: profile.monthlyLimit,
                        dailyLimit: profile.dailyLimit
                    )
                }

                return profile.toUser()
            }
            
            // Si no existe y no es el último intento, esperar
            if attempt < maxRetries - 1 {
                let delay = UInt64(pow(2.0, Double(attempt))) * 100_000_000 // Exponential backoff: 100ms, 200ms, 400ms, 800ms, 1.6s
                try await Task.sleep(nanoseconds: delay)
            }
        }

        // Si después de los reintentos no existe, crear el perfil usando upsert
        let newProfile = SupabaseProfile(
            id: authUser.id.uuidString,
            fullName: fullName ?? authUser.email?.components(separatedBy: "@").first ?? "Usuario",
            email: email ?? authUser.email ?? "",
            role: role.rawValue,
            phone: phone,
            benefactorId: nil,
            monthlyLimit: nil,
            dailyLimit: nil
        )

        do {
            try await client
                .from(SupabaseConfig.Tables.profiles)
                .upsert(newProfile, onConflict: "id")
                .execute()
        } catch {
            // Si upsert falla, podría ser que el perfil fue creado por otro request
            // Intentar leerlo una última vez
            if let profile = try? await fetchExistingProfile(for: authUser) {
                return profile
            }
            throw AppError.profileCreationFailed
        }

        return newProfile.toUser()
    }
    
    // Helper para buscar perfil existente sin retry
    private func fetchExistingProfile(for authUser: Supabase.User) async throws -> User {
        let response = try await client
            .from(SupabaseConfig.Tables.profiles)
            .select()
            .eq("id", value: authUser.id.uuidString)
            .single()
            .execute()
        
        guard let data = response.data,
              let profile = try JSONDecoder().decode(SupabaseProfile.self, from: data) else {
            throw AppError.userNotFound
        }
        
        return profile.toUser()
    }
    
    // Versión simple sin retry para Google Sign-In (donde no hay trigger)
    private func fetchOrCreateProfile(
        for authUser: Supabase.User,
        fullName: String? = nil,
        email: String? = nil,
        role: UserRole = .benefactor,
        phone: String? = nil
    ) async throws -> User {

        // Intentar buscar el perfil existente
        let response = try? await client
            .from(SupabaseConfig.Tables.profiles)
            .select()
            .eq("id", value: authUser.id.uuidString)
            .single()
            .execute()

        // Si existe, mapearlo
        if let data = response?.data,
           let profile = try? JSONDecoder().decode(SupabaseProfile.self, from: data) {

            // Si el rol es diferente, actualizarlo
            if UserRole(rawValue: profile.role) != role {
                try await client
                    .from(SupabaseConfig.Tables.profiles)
                    .update(["role": role.rawValue])
                    .eq("id", value: authUser.id.uuidString)
                    .execute()

                return User(
                    id: UUID(uuidString: profile.id) ?? UUID(),
                    fullName: fullName ?? profile.fullName,
                    email: email ?? profile.email,
                    role: role,
                    benefactorID: profile.benefactorId.flatMap { UUID(uuidString: $0) },
                    monthlyLimit: profile.monthlyLimit,
                    dailyLimit: profile.dailyLimit
                )
            }

            return profile.toUser()
        }

        // Si no existe, crear el perfil usando upsert para evitar race conditions
        let newProfile = SupabaseProfile(
            id: authUser.id.uuidString,
            fullName: fullName ?? authUser.email?.components(separatedBy: "@").first ?? "Usuario",
            email: email ?? authUser.email ?? "",
            role: role.rawValue,
            phone: phone,
            benefactorId: nil,
            monthlyLimit: nil,
            dailyLimit: nil
        )

        try await client
            .from(SupabaseConfig.Tables.profiles)
            .upsert(newProfile, onConflict: "id")
            .execute()

        return newProfile.toUser()
    }
    
    // Mapear errores de Supabase a AppError
    private func mapSupabaseError(_ error: Error) -> AppError {
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

