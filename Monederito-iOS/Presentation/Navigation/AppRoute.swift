//
//  AppRoute.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import Foundation

// CONCEPTO: Enum como sistema de rutas tipadas
// En lugar de navegar con Strings ("ir a pantalla X"),
// usamos enums. El compilador te avisa si te olvidás un caso.
// Esto es lo que tu entrevistador llama "navigation" en SwiftUI.

// Rutas del Benefactor (Elena/Pedro)
enum BenefactorRoute: Hashable {
    case dashboard
    case alertDetail(RiskAlert)
    case beneficiaryDetail(BeneficiaryAccount)
    case addBeneficiary
    case settings
    case financialEducation
}

// Rutas del Beneficiario (Lucas)
enum BeneficiaryRoute: Hashable {
    case wallet
    case transactionDetail(Transaction)
    case requestMoney
    case savingsGoal
    case financialEducation
}

// CONCEPTO: Hashable es necesario para que NavigationStack
// pueda usar estos enums como destinos de navegación.
// RiskAlert y Transaction ya conforman Equatable (via Codable),
// pero necesitamos Hashable. Lo agregamos con una extension:

extension RiskAlert: Hashable {
    static func == (lhs: RiskAlert, rhs: RiskAlert) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Transaction: Hashable {
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension BeneficiaryAccount: Hashable {
    static func == (lhs: BeneficiaryAccount, rhs: BeneficiaryAccount) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
