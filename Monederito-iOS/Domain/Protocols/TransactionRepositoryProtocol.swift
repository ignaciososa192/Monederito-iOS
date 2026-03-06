//
//  TransactionRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// CONCEPTO: Generics — funciones/tipos que trabajan con cualquier tipo T
// que cumpla ciertas condiciones. Hace el código reutilizable.
// El entrevistador mencionó esto como área de mejora.

protocol TransactionRepositoryProtocol {
    func getTransactions(for userID: UUID) async throws -> [Transaction]
    func getRecentTransactions(for userID: UUID, limit: Int) async throws -> [Transaction]
    func createTransaction(_ transaction: Transaction) async throws -> Transaction
    func getPendingAlerts(for benefactorID: UUID) async throws -> [RiskAlert]
    func resolveAlert(alertID: UUID, status: AlertStatus) async throws -> RiskAlert
    func getMonthlySpending(for userID: UUID) async throws -> [TransactionCategory: Double]
}
