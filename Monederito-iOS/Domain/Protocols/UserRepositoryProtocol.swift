//
//  UserRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

protocol UserRepositoryProtocol: AnyObject {
    func getBeneficiaryAccounts(for benefactorID: UUID) async throws -> [BeneficiaryAccount]
    func updateBeneficiaryAccount(_ account: BeneficiaryAccount) async throws -> BeneficiaryAccount
    func getSavingsGoals(for userID: UUID) async throws -> [SavingsGoal]
    func createSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal
    func updateSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal
}
