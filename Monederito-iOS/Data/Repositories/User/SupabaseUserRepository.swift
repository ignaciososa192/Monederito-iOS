//
//  SupabaseUserRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation
import Supabase

final class SupabaseUserRepository: UserRepositoryProtocol {
    
    private let client: SupabaseClient
    
    init() {
        guard let client = SupabaseConfig.client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
        self.client = client
    }
    
    // MARK: - UserRepositoryProtocol
    
    func getBeneficiaryAccounts(for benefactorID: UUID) async throws -> [BeneficiaryAccount] {
        
        let response = try await client.from(SupabaseConfig.Tables.beneficiaryAccounts)
            .select()
            .eq("benefactor_id", value: benefactorID.uuidString)
            .execute()
        
        let accounts: [SupabaseBeneficiaryAccount] = try JSONDecoder().decode([SupabaseBeneficiaryAccount].self, from: response.data)
        return accounts.map { $0.toBeneficiaryAccount() }
    }
    
    func updateBeneficiaryAccount(_ account: BeneficiaryAccount) async throws -> BeneficiaryAccount {
        
        struct UpdateData: Encodable {
            let dailyLimit: Double
            let monthlyLimit: Double
            let blockedCategories: [String]
            
            enum CodingKeys: String, CodingKey {
                case dailyLimit = "daily_limit"
                case monthlyLimit = "monthly_limit"
                case blockedCategories = "blocked_categories"
            }
        }
        
        let updateData = UpdateData(
            dailyLimit: account.dailyLimit,
            monthlyLimit: account.monthlyLimit,
            blockedCategories: account.blockedCategories.map { $0.rawValue }
        )
        
        let response = try await client.from(SupabaseConfig.Tables.beneficiaryAccounts)
            .update(updateData)
            .eq("id", value: account.id.uuidString)
            .select()
            .single()
            .execute()
        
        let updatedAccount: SupabaseBeneficiaryAccount = try JSONDecoder().decode(SupabaseBeneficiaryAccount.self, from: response.data)
        return updatedAccount.toBeneficiaryAccount()
    }
    
    func getSavingsGoals(for userID: UUID) async throws -> [SavingsGoal] {
        
        let response = try await client.from(SupabaseConfig.Tables.savingsGoals)
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
        
        let goals: [SupabaseSavingsGoal] = try JSONDecoder().decode([SupabaseSavingsGoal].self, from: response.data)
        return goals.map { $0.toSavingsGoal() }
    }
    
    func createSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal {
        
        let dateFormatter = ISO8601DateFormatter()
        let supabaseGoal = SupabaseSavingsGoal(
            id: goal.id.uuidString,
            title: goal.title,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            emoji: goal.emoji,
            deadline: goal.deadline != nil ? dateFormatter.string(from: goal.deadline!) : nil,
            isCompleted: goal.isCompleted
        )
        
        let response = try await client.from(SupabaseConfig.Tables.savingsGoals)
            .insert(supabaseGoal)
            .select()
            .single()
            .execute()
        
        let createdGoal: SupabaseSavingsGoal = try JSONDecoder().decode(SupabaseSavingsGoal.self, from: response.data)
        return createdGoal.toSavingsGoal()
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) async throws -> SavingsGoal {
        
        let dateFormatter = ISO8601DateFormatter()
        
        struct UpdateData: Encodable {
            let currentAmount: Double
            let title: String
            let targetAmount: Double
            let isCompleted: Bool
            let deadline: String?
            
            enum CodingKeys: String, CodingKey {
                case currentAmount = "current_amount"
                case title
                case targetAmount = "target_amount"
                case isCompleted = "is_completed"
                case deadline
            }
        }
        
        let updateData = UpdateData(
            currentAmount: goal.currentAmount,
            title: goal.title,
            targetAmount: goal.targetAmount,
            isCompleted: goal.isCompleted,
            deadline: goal.deadline != nil ? dateFormatter.string(from: goal.deadline!) : nil
        )
        
        let response = try await client.from(SupabaseConfig.Tables.savingsGoals)
            .update(updateData)
            .eq("id", value: goal.id.uuidString)
            .select()
            .single()
            .execute()
        
        let updatedGoal: SupabaseSavingsGoal = try JSONDecoder().decode(SupabaseSavingsGoal.self, from: response.data)
        return updatedGoal.toSavingsGoal()
    }
}

// MARK: - DTOs for Supabase

struct SupabaseBeneficiaryAccount: Codable {
    let id: String
    let beneficiaryID: String
    let benefactorID: String
    let nickname: String
    let dailyLimit: Double
    let monthlyLimit: Double
    let allowedCategories: [String]
    let blockedCategories: [String]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case beneficiaryID   = "beneficiary_id"
        case benefactorID    = "benefactor_id"  // FIXED: Database has separate columns
        case nickname
        case dailyLimit      = "daily_limit"
        case monthlyLimit    = "monthly_limit"
        case allowedCategories = "allowed_categories"
        case blockedCategories = "blocked_categories"
        case isActive        = "is_active"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        // FIXED: Database now has separate columns: beneficiary_id and benefactor_id
        beneficiaryID = try container.decode(String.self, forKey: .beneficiaryID)
        benefactorID = try container.decode(String.self, forKey: .benefactorID)
        
        nickname = try container.decode(String.self, forKey: .nickname)
        dailyLimit = try container.decode(Double.self, forKey: .dailyLimit)
        monthlyLimit = try container.decode(Double.self, forKey: .monthlyLimit)
        allowedCategories = (try? container.decode([String].self, forKey: .allowedCategories)) ?? []
        blockedCategories = (try? container.decode([String].self, forKey: .blockedCategories)) ?? []
        isActive = (try? container.decode(Bool.self, forKey: .isActive)) ?? true
    }
    
    func toBeneficiaryAccount() -> BeneficiaryAccount {
        BeneficiaryAccount(
            id: UUID(uuidString: id) ?? UUID(),
            beneficiaryID: UUID(uuidString: beneficiaryID) ?? UUID(),
            benefactorID: UUID(uuidString: benefactorID) ?? UUID(),
            nickname: nickname,
            monthlyLimit: monthlyLimit,
            dailyLimit: dailyLimit,
            allowedCategories: allowedCategories.compactMap { TransactionCategory(rawValue: $0) },
            blockedCategories: blockedCategories.compactMap { TransactionCategory(rawValue: $0) },
            isActive: isActive
        )
    }
}

struct SupabaseSavingsGoal: Codable {
    let id: String
    let title: String
    let targetAmount: Double
    let currentAmount: Double
    let emoji: String
    let deadline: String?
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case targetAmount    = "target_amount"
        case currentAmount   = "current_amount"
        case emoji
        case deadline
        case isCompleted     = "is_completed"
    }
    
    func toSavingsGoal() -> SavingsGoal {
        let dateFormatter = ISO8601DateFormatter()
        return SavingsGoal(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            emoji: emoji,
            deadline: deadline != nil ? dateFormatter.date(from: deadline!) : nil,
            isCompleted: isCompleted
        )
    }
}
