//
//  BeneficiaryDashboardViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

@Observable
class BeneficiaryDashboardViewModel {
    
    // MARK: - State
    var transactions: [Transaction] = []
    var savingsGoals: [SavingsGoal] = []
    var beneficiaryAccount: BeneficiaryAccount? = nil
    var isLoading: Bool = false
    
    // MARK: - Computed usando Generics (Summarizable protocol)
    var summary: TransactionSummary? {
        transactions.isEmpty ? nil : transactions.makeSummary()
    }
    
    var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }
    
    var activeGoals: [SavingsGoal] {
        savingsGoals.filter { !$0.isCompleted }
    }
    
    var completedGoals: [SavingsGoal] {
        savingsGoals.filter { $0.isCompleted }
    }
    
    // MARK: - Load
    func loadData(for userID: UUID) async {
        isLoading = true
        
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
            transactions = MockData.transactions
            savingsGoals = MockData.savingsGoals
            beneficiaryAccount = MockData.beneficiaryAccount
        } catch {
            print("Error cargando datos: \(error)")
        }
        
        isLoading = false
    }
}
