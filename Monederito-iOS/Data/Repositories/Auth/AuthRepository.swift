//
//  AuthRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

// CONCEPTO: Clase que implementa el protocolo
// MockAuthRepository CONFORMA AuthRepositoryProtocol.
// El ViewModel solo ve el protocolo — nunca esta clase directamente.
// Cuando conectemos Supabase, creamos SupabaseAuthRepository
// que también conforma el mismo protocolo, y el ViewModel
// NO necesita cambiar ni una línea.

final class MockAuthRepository: AuthRepositoryProtocol {
    
    // CONCEPTO: Simulated delay — hace el mock realista
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await simulateNetworkDelay()
        
        // Simulamos validación
        guard !email.isEmpty && !password.isEmpty else {
            throw AppError.invalidCredentials
        }
        
        // Retornamos usuario según email
        if email.contains("elena") {
            return MockData.benefactorUser
        } else if email.contains("lucas") {
            return MockData.beneficiaryUser
        }
        
        throw AppError.userNotFound
    }
    
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> User {
        try await simulateNetworkDelay()
        
        guard email.contains("@") else { throw AppError.invalidCredentials }
        
        return User(
            fullName: fullName,
            email: email,
            role: role
        )
    }
    
    func signOut() async throws {
        try await simulateNetworkDelay()
        // En Supabase: try await supabase.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        try await simulateNetworkDelay()
        return nil // No hay sesión persistida en mock
    }
    
    func resetPassword(email: String) async throws {
        try await simulateNetworkDelay()
        guard email.contains("@") else { throw AppError.invalidCredentials }
        // En Supabase: try await supabase.auth.resetPasswordForEmail(email)
    }
    
    func updateProfile(_ user: User) async throws -> User {
        try await simulateNetworkDelay()
        return user
    }
    
    func enableBiometrics() async throws {
        try await simulateNetworkDelay()
        // En iOS: integración con LocalAuthentication framework
    }
}
