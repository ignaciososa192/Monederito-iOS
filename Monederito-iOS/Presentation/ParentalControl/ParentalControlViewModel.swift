//
//  ParentalControlViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

@Observable
class ParentalControlViewModel {
    
    // MARK: - State
    var beneficiaryAccounts: [BeneficiaryAccount] = []
    var selectedAccount: BeneficiaryAccount? = nil
    var isLoading: Bool = false
    var showingLimitConfig: Bool = false
    var showingCategoryConfig: Bool = false
    var successMessage: String? = nil
    
    // MARK: - Load
    func loadAccounts(for benefactorID: UUID) async {
        isLoading = true
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            beneficiaryAccounts = [MockData.beneficiaryAccount]
        } catch { }
        isLoading = false
    }
    
    // MARK: - Actions
    
    // CONCEPTO: @escaping closure con [weak self]
    // Cuando pasamos un closure que se ejecuta después (async),
    // debemos usar [weak self] para evitar retain cycles.
    // Un retain cycle es cuando dos objetos se retienen mutuamente
    // y ninguno puede ser liberado de memoria — memory leak.
    
    func updateDailyLimit(_ limit: Double, for account: BeneficiaryAccount) async {
        guard let index = beneficiaryAccounts.firstIndex(where: { $0.id == account.id }) else { return }
        
        // Optimistic update
        beneficiaryAccounts[index].dailyLimit = limit
        selectedAccount?.dailyLimit = limit
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            // En Paso 7: try await repository.updateAccount(beneficiaryAccounts[index])
            successMessage = "Límite diario actualizado ✅"
        } catch { }
        
        // Limpiar mensaje después de 2 segundos
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        successMessage = nil
    }
    
    func updateMonthlyLimit(_ limit: Double, for account: BeneficiaryAccount) async {
        guard let index = beneficiaryAccounts.firstIndex(where: { $0.id == account.id }) else { return }
        beneficiaryAccounts[index].monthlyLimit = limit
        selectedAccount?.monthlyLimit = limit
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            successMessage = "Límite mensual actualizado ✅"
        } catch { }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        successMessage = nil
    }
    
    func toggleCategory(_ category: TransactionCategory, blocked: Bool, for account: BeneficiaryAccount) async {
        guard let index = beneficiaryAccounts.firstIndex(where: { $0.id == account.id }) else { return }
        
        if blocked {
            if !beneficiaryAccounts[index].blockedCategories.contains(category) {
                beneficiaryAccounts[index].blockedCategories.append(category)
                selectedAccount?.blockedCategories.append(category)
            }
        } else {
            beneficiaryAccounts[index].blockedCategories.removeAll { $0 == category }
            selectedAccount?.blockedCategories.removeAll { $0 == category }
        }
        
        successMessage = "\(category.rawValue) \(blocked ? "bloqueada" : "permitida") ✅"
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        successMessage = nil
    }
    
    func toggleAccount(_ account: BeneficiaryAccount) async {
        guard let index = beneficiaryAccounts.firstIndex(where: { $0.id == account.id }) else { return }
        beneficiaryAccounts[index].isActive.toggle()
        selectedAccount?.isActive = beneficiaryAccounts[index].isActive
    }
}
