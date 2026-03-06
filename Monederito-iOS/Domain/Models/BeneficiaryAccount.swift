//
//  BeneficiaryAccount.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// Representa la cuenta supervisada que el benefactor configura para su beneficiario.
// Viene del Mapa de Sitio: "Registra cuentas supervisadas" → "Envío link descarga app"

struct BeneficiaryAccount: Identifiable, Codable {
    let id: UUID
    let beneficiaryID: UUID
    let benefactorID: UUID
    var nickname: String            // "Lucas (mi hijo)", "Papá"
    var monthlyLimit: Double
    var dailyLimit: Double
    var allowedCategories: [TransactionCategory]
    var blockedCategories: [TransactionCategory]
    var isActive: Bool
    
    // CONCEPTO: computed property que usa otra propiedad
    var hasRiskyCategories: Bool {
        blockedCategories.contains(where: \.isRisky)
    }
    
    // Límite de gasto restante este mes (se calculará con las transacciones reales)
    var remainingMonthlyBudget: Double = 0
    
    init(
        id: UUID = UUID(),
        beneficiaryID: UUID,
        benefactorID: UUID,
        nickname: String,
        monthlyLimit: Double = 50000,
        dailyLimit: Double = 5000,
        allowedCategories: [TransactionCategory] = TransactionCategory.allCases.filter { !$0.isRisky },
        blockedCategories: [TransactionCategory] = [.gambling, .highRiskInvest],
        isActive: Bool = true
    ) {
        self.id = id
        self.beneficiaryID = beneficiaryID
        self.benefactorID = benefactorID
        self.nickname = nickname
        self.monthlyLimit = monthlyLimit
        self.dailyLimit = dailyLimit
        self.allowedCategories = allowedCategories
        self.blockedCategories = blockedCategories
        self.isActive = isActive
    }
}
