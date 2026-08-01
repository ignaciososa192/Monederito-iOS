//
//  SupabaseTransactionRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation
import Supabase

final class SupabaseTransactionRepository: TransactionRepositoryProtocol {
    
    private let client: SupabaseClient
    
    init() {
        guard let client = SupabaseConfig.client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
        self.client = client
    }
    
    // MARK: - TransactionRepositoryProtocol
    
    func getTransactions(for userID: UUID, limit: Int? = nil) async throws -> [Transaction] {
        
        var query = client.from(SupabaseConfig.Tables.transactions)
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: false)
        
        if let limit = limit {
            query = query.limit(limit)
        }
        
        let response = try await query.execute()
        let transactions: [SupabaseTransaction] = try JSONDecoder().decode([SupabaseTransaction].self, from: response.data)
        
        return transactions.map { $0.toTransaction() }
    }
    
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        
        let supabaseTransaction = SupabaseTransaction(
            id: transaction.id.uuidString,
            userID: transaction.userID.uuidString,
            amount: transaction.amount,
            category: transaction.category.rawValue,
            merchant: transaction.merchant,
            date: ISO8601DateFormatter().string(from: transaction.date),
            status: transaction.status.rawValue
        )
        
        let response = try await client.from(SupabaseConfig.Tables.transactions)
            .insert(supabaseTransaction)
            .select()
            .single()
            .execute()
        
        let createdTransaction: SupabaseTransaction = try JSONDecoder().decode(SupabaseTransaction.self, from: response.data)
        return createdTransaction.toTransaction()
    }
    
    func getPendingAlerts(for benefactorID: UUID) async throws -> [RiskAlert] {
        
        let response = try await client.from(SupabaseConfig.Tables.riskAlerts)
            .select()
            .eq("benefactor_id", value: benefactorID.uuidString)
            .eq("status", value: "pending")
            .execute()
        
        let alerts: [SupabaseRiskAlert] = try JSONDecoder().decode([SupabaseRiskAlert].self, from: response.data)
        return alerts.map { $0.toRiskAlert() }
    }
    
    func resolveAlert(alertID: UUID, status: AlertStatus) async throws -> RiskAlert {
        
        let response = try await client.from(SupabaseConfig.Tables.riskAlerts)
            .update([
                "status": status.rawValue,
                "resolved_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: alertID.uuidString)
            .select()
            .single()
            .execute()
        
        let alert: SupabaseRiskAlert = try JSONDecoder().decode(SupabaseRiskAlert.self, from: response.data)
        return alert.toRiskAlert()
    }
    
    func getMonthlySpending(for userID: UUID) async throws -> [TransactionCategory: Double] {
        
        // Calculate start of current month
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        let response = try await client.from(SupabaseConfig.Tables.transactions)
            .select("category, amount")
            .eq("user_id", value: userID.uuidString)
            .gte("created_at", value: ISO8601DateFormatter().string(from: startDate))
            .execute()
        
        let transactions: [SupabaseTransaction] = try JSONDecoder().decode([SupabaseTransaction].self, from: response.data)
        
        // Aggregate by category
        var spendingByCategory: [TransactionCategory: Double] = [:]
        for transaction in transactions {
            if let category = TransactionCategory(rawValue: transaction.category) {
                spendingByCategory[category, default: 0] += transaction.amount
            }
        }
        
        return spendingByCategory
    }
}

// MARK: - DTOs for Supabase

struct SupabaseTransaction: Codable {
    let id: String
    let userID: String
    let amount: Double
    let category: String
    let merchant: String
    let date: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID     = "user_id"
        case amount
        case category
        case merchant
        case date        = "created_at"
        case status
    }
    
    func toTransaction() -> Transaction {
        Transaction(
            id: UUID(uuidString: id) ?? UUID(),
            userID: UUID(uuidString: userID) ?? UUID(),
            amount: amount,
            category: TransactionCategory(rawValue: category) ?? .unknown,
            merchant: merchant,
            date: ISO8601DateFormatter().date(from: date) ?? Date(),
            status: Transaction.TransactionStatus(rawValue: status) ?? .completed
        )
    }
}

struct SupabaseRiskAlert: Codable {
    let id: String
    let benefactorID: String
    let transactionID: String
    let riskCategory: String
    let description: String
    let status: String
    let createdAt: String
    let resolvedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case benefactorID    = "benefactor_id"
        case transactionID   = "transaction_id"
        case riskCategory    = "risk_category"
        case description
        case status
        case createdAt       = "created_at"
        case resolvedAt      = "resolved_at"
    }
    
    func toRiskAlert() -> RiskAlert {
        // Break down complex conversions to help the type-checker
        let parsedID: UUID = UUID(uuidString: id) ?? UUID()
        let parsedBenefactorID: UUID = UUID(uuidString: benefactorID) ?? UUID()
        let parsedTransactionID: UUID = UUID(uuidString: transactionID) ?? UUID()

        let dateFormatter = ISO8601DateFormatter()
        let parsedCreatedAt: Date = dateFormatter.date(from: createdAt) ?? Date()
        let parsedResolvedAt: Date? = {
            if let resolvedAt = resolvedAt, let date = dateFormatter.date(from: resolvedAt) {
                return date
            }
            return nil
        }()

        return RiskAlert(
            id: parsedID,
            transactionID: parsedTransactionID,
            beneficiaryID: parsedBenefactorID,
            benefactorID: UUID(),
            amount: 0,
            merchant: "",
            category: TransactionCategory(rawValue: riskCategory) ?? .unknown,
            createdAt: parsedCreatedAt,
            resolvedAt: parsedResolvedAt
        )
    }
}

