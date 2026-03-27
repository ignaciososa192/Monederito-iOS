//
//  DashboardViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

@Observable
class DashboardViewModel {
    
    // MARK: - State
    var pendingAlerts: [RiskAlert] = []
    var recentTransactions: [Transaction] = []
    var beneficiaryAccounts: [BeneficiaryAccount] = []
    var spendingByCategory: [TransactionCategory: Double] = [:]
    var isLoading: Bool = false
    var error: AppError? = nil
    
    // MARK: - Computed
    var totalMonthlySpending: Double { spendingByCategory.values.reduce(0, +) }
    var urgentAlerts: [RiskAlert] { pendingAlerts.filter { $0.isUrgent } }
    var chartData: [(category: TransactionCategory, amount: Double)] {
        spendingByCategory.sorted { $0.value > $1.value }.map { (category: $0.key, amount: $0.value) }
    }
    
    // MARK: - Load con repositorios reales
    func loadDashboard(
        for userID: UUID,
        transactionRepo: any TransactionRepositoryProtocol,
        userRepo: any UserRepositoryProtocol
    ) async {
        isLoading = true
        error = nil
        
        // CONCEPTO: async let — ejecuta múltiples tareas en PARALELO
        // En lugar de esperar una por una, las lanzamos todas juntas.
        // El tiempo total = el de la más lenta (no la suma de todas)
        async let alertsTask = transactionRepo.getPendingAlerts(for: userID)
        async let transactionsTask = transactionRepo.getTransactions(for: userID, limit: 10)
        async let accountsTask = userRepo.getBeneficiaryAccounts(for: userID)
        async let spendingTask = transactionRepo.getMonthlySpending(for: userID)
        
        do {
            let (alerts, transactions, accounts, spending) = try await (
                alertsTask,
                transactionsTask,
                accountsTask,
                spendingTask
            )
            
            pendingAlerts = alerts
            recentTransactions = transactions
            beneficiaryAccounts = accounts
            spendingByCategory = spending
            
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.serverError(code: 0, message: error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func resolveAlert(_ alert: RiskAlert, status: AlertStatus, using repo: any TransactionRepositoryProtocol) async {
        // Optimistic update
        pendingAlerts.removeAll { $0.id == alert.id }
        
        do {
            _ = try await repo.resolveAlert(alertID: alert.id, status: status)
        } catch {
            // Si falla, restauramos la alerta
            pendingAlerts.append(alert)
        }
    }
}
