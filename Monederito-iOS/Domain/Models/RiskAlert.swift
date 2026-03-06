//
//  RiskAlert.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// Este modelo es la pieza CENTRAL del Task Flow del PDF.
// Representa el momento en que el sistema detecta un gasto riesgoso
// y le pide aprobación al benefactor.

struct RiskAlert: Identifiable, Codable {
    let id: UUID
    let transactionID: UUID
    let beneficiaryID: UUID
    let benefactorID: UUID
    let amount: Double
    let merchant: String
    let category: TransactionCategory
    let createdAt: Date
    var status: AlertStatus
    var resolvedAt: Date?
    var educationalTip: String  // tip de educación financiera para el beneficiario
    
    // CONCEPTO: propiedad computada con lógica de negocio
    var isUrgent: Bool {
        guard status.isPending else { return false }
        let minutesSinceCreated = Date().timeIntervalSince(createdAt) / 60
        return minutesSinceCreated > 3 // urgente si lleva más de 3 minutos sin resolver
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    init(
        id: UUID = UUID(),
        transactionID: UUID,
        beneficiaryID: UUID,
        benefactorID: UUID,
        amount: Double,
        merchant: String,
        category: TransactionCategory,
        createdAt: Date = Date(),
        status: AlertStatus = .pending,
        resolvedAt: Date? = nil,
        educationalTip: String = ""
    ) {
        self.id = id
        self.transactionID = transactionID
        self.beneficiaryID = beneficiaryID
        self.benefactorID = benefactorID
        self.amount = amount
        self.merchant = merchant
        self.category = category
        self.createdAt = createdAt
        self.status = status
        self.resolvedAt = resolvedAt
        self.educationalTip = educationalTip
    }
}
