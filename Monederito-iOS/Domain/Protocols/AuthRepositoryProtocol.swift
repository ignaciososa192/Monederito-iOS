//
//  AuthRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// CONCEPTO CLAVE: Protocol como interfaz (del comentario del entrevistador)
// Un protocol define QUÉ se puede hacer, sin decir CÓMO.
// Esto permite tener una implementación real (Supabase) y una de prueba (mock)
// sin cambiar ni una línea de los ViewModels.

// CONCEPTO: async throws — función asíncrona que puede fallar
// - async: no bloquea el hilo principal mientras espera la red
// - throws: puede lanzar un error que debés capturar con try/catch

enum SignUpResult {
    case authenticated(User)
    case confirmationRequired(email: String)
}

enum AuthSessionEvent { case signedOut, passwordRecovery }

protocol AuthRepositoryProtocol: AnyObject {
    
    // CONCEPTO: async throws
    // - async: no bloquea el hilo principal
    // - throws: puede lanzar un AppError
    // El caller debe usar: try await
    
    func signIn(email: String, password: String) async throws -> User
    func signInWithGoogle(role: UserRole?) async throws -> User
    func signUp(
        email: String,
        password: String,
        fullName: String,
        role: UserRole,
        phone: String
    ) async throws -> SignUpResult
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func resetPassword(email: String) async throws
    func updatePassword(_ password: String) async throws
    func handleAuthCallback(_ url: URL) async throws
    func sessionEvents() -> AsyncStream<AuthSessionEvent>
    func updateProfile(_ user: User) async throws -> User
    func enableBiometrics() async throws
}

// Non-network test doubles may opt out of callbacks/events.
extension AuthRepositoryProtocol {
    func updatePassword(_ password: String) async throws { throw AppError.authenticationFailed }
    func handleAuthCallback(_ url: URL) async throws { throw AppError.authenticationFailed }
    func sessionEvents() -> AsyncStream<AuthSessionEvent> { AsyncStream { $0.finish() } }
}
