//
//  TransactionRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

final class MockTransactionRepository: TransactionRepositoryProtocol {
    
    private func delay() async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }
    
    func getTransactions(for userID: UUID, limit: Int? = nil) async throws -> [Transaction] {
        try await delay()
        let all = MockData.transactions.filter { $0.userID == userID }
        if let limit { return Array(all.prefix(limit)) }
        return all
    }
    
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        try await delay()
        
        // Validar si la categoría es riesgosa → lanzar error especial
        if transaction.category.isRisky {
            throw AppError.transactionBlocked(reason: "Categoría de riesgo detectada")
        }
        
        return transaction
    }
    
    func getPendingAlerts(for benefactorID: UUID) async throws -> [RiskAlert] {
        try await delay()
        return [MockData.pendingAlert].filter { $0.benefactorID == benefactorID }
    }
    
    func resolveAlert(alertID: UUID, status: AlertStatus) async throws -> RiskAlert {
        try await delay()
        var alert = MockData.pendingAlert
        alert.status = status
        alert.resolvedAt = Date()
        return alert
    }
    
    func getMonthlySpending(for userID: UUID) async throws -> [TransactionCategory: Double] {
        try await delay()
        return MockData.spendingByCategory
    }
}
