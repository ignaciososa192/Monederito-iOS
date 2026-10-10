//
//  AuthRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

final class MockAuthRepository: AuthRepositoryProtocol {
    private var currentUser: User?
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await simulateNetworkDelay()
        guard !email.isEmpty && !password.isEmpty else {
            throw AppError.invalidCredentials
        }
        if email.contains("elena") { currentUser = MockData.benefactorUser; return MockData.benefactorUser }
        if email.contains("lucas") { currentUser = MockData.beneficiaryUser; return MockData.beneficiaryUser }
        throw AppError.userNotFound
    }
    
    func signInWithGoogle(role: UserRole?) async throws -> User {
        try await simulateNetworkDelay()
        // Mock retorna el rol seleccionado o benefactor por defecto
        let user = role == .beneficiary ? MockData.beneficiaryUser : MockData.benefactorUser
        currentUser = user
        return user
    }
    
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> SignUpResult {
        try await simulateNetworkDelay()
        guard email.contains("@") else { throw AppError.invalidCredentials }
        let user = User(fullName: fullName, email: email, role: role)
        currentUser = user
        return .authenticated(user)
    }
    
    func signOut() async throws {
        currentUser = nil
        try await simulateNetworkDelay()
    }
    
    func getCurrentUser() async throws -> User? {
        try await simulateNetworkDelay()
        return currentUser
    }
    
    func resetPassword(email: String) async throws {
        try await simulateNetworkDelay()
        guard email.contains("@") else { throw AppError.invalidCredentials }
    }
    
    func updatePassword(_ password: String) async throws {
        guard password.count >= 8, currentUser != nil else { throw AppError.authenticationFailed }
    }

    func updateProfile(_ user: User) async throws -> User {
        try await simulateNetworkDelay()
        return user
    }
    
    func enableBiometrics() async throws {
        try await simulateNetworkDelay()
    }
}
