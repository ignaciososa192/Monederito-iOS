//
//  Transaction.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID            // ¿quién realizó la transacción?
    let amount: Double          // monto en ARS
    let category: TransactionCategory
    let merchant: String        // nombre del comercio (ej: "CasinoRoyale Online")
    let date: Date
    var status: TransactionStatus
    var alertID: UUID?          // si generó una alerta, la referencia
    
    // CONCEPTO: enum anidado dentro de struct — organización limpia
    enum TransactionStatus: String, Codable {
        case completed = "Completada"
        case blocked   = "Bloqueada"
        case pending   = "Pendiente aprobación"
    }
    
    var isRisky: Bool { category.isRisky }
    
    // Formateo de moneda en pesos argentinos
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        amount: Double,
        category: TransactionCategory,
        merchant: String,
        date: Date = Date(),
        status: TransactionStatus = .completed,
        alertID: UUID? = nil
    ) {
        self.id = id
        self.userID = userID
        self.amount = amount
        self.category = category
        self.merchant = merchant
        self.date = date
        self.status = status
        self.alertID = alertID
    }
}
