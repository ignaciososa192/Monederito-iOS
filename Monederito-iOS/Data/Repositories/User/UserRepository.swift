//
//  UserRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

final class MockUserRepository: UserRepositoryProtocol {
    
    private func delay() async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }
    
    func getBeneficiaryAccounts(for benefactorID: UUID) async throws -> [BeneficiaryAccount] {
        try await delay()
        return [MockData.beneficiaryAccount]
    }
    
    func updateBeneficiaryAccount(_ account: BeneficiaryAccount) async throws -> BeneficiaryAccount {
        try await delay()
        return account
    }
    
    func getSavingsGoals(for userID: UUID) async throws -> [SavingsGoal] {
        try await delay()
        return MockData.savingsGoals
    }
    
    func createSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal {
        try await delay()
        return goal
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal {
        try await delay()
        return goal
    }
}
