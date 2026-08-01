//
//  AuthRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

final class MockAuthRepository: AuthRepositoryProtocol {
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await simulateNetworkDelay()
        guard !email.isEmpty && !password.isEmpty else {
            throw AppError.invalidCredentials
        }
        if email.contains("elena") { return MockData.benefactorUser }
        if email.contains("lucas") { return MockData.beneficiaryUser }
        throw AppError.userNotFound
    }
    
    func signInWithGoogle(role: UserRole?) async throws -> User {
        try await simulateNetworkDelay()
        // Mock retorna el rol seleccionado o benefactor por defecto
        return role == .beneficiary ? MockData.beneficiaryUser : MockData.benefactorUser
    }
    
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> User {
        try await simulateNetworkDelay()
        guard email.contains("@") else { throw AppError.invalidCredentials }
        return User(fullName: fullName, email: email, role: role)
    }
    
    func signOut() async throws {
        try await simulateNetworkDelay()
    }
    
    func getCurrentUser() async throws -> User? {
        try await simulateNetworkDelay()
        return nil
    }
    
    func resetPassword(email: String) async throws {
        try await simulateNetworkDelay()
        guard email.contains("@") else { throw AppError.invalidCredentials }
    }
    
    func updateProfile(_ user: User) async throws -> User {
        try await simulateNetworkDelay()
        return user
    }
    
    func enableBiometrics() async throws {
        try await simulateNetworkDelay()
    }
}
