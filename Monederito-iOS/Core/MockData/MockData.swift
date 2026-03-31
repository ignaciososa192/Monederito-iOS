//
//  MockData.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// CONCEPTO: Mock data — datos de prueba para desarrollar sin backend.
// Esto es lo que usaremos hasta conectar Supabase en el Paso 7.

struct MockData {
    
    static let benefactorUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        fullName: "Elena García",
        email: "elena@email.com",
        role: .benefactor
    )
    
    static let beneficiaryUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        fullName: "Lucas García",
        email: "lucas@email.com",
        role: .beneficiary,
        benefactorID: benefactorUser.id
    )
    
    static let beneficiaryAccount = BeneficiaryAccount(
        beneficiaryID: beneficiaryUser.id,
        benefactorID: benefactorUser.id,
        nickname: "Lucas (mi hijo)",
        monthlyLimit: 80000,
        dailyLimit: 8000
    )
    
    static let pendingAlert = RiskAlert(
        transactionID: UUID(),
        beneficiaryID: beneficiaryUser.id,
        benefactorID: benefactorUser.id,
        amount: 250000,
        merchant: "CasinoRoyale Online",
        category: .gambling,
        educationalTip: "Las apuestas online tienen una tasa de pérdida del 97%. Este dinero podría usarse para 3 meses de transporte o ahorros."
    )
    
    static let transactions: [Transaction] = [
        Transaction(userID: beneficiaryUser.id, amount: 1500, category: .food, merchant: "McDonald's"),
        Transaction(userID: beneficiaryUser.id, amount: 800, category: .transport, merchant: "SUBE"),
        Transaction(userID: beneficiaryUser.id, amount: 3200, category: .entertainment, merchant: "Netflix"),
        Transaction(userID: beneficiaryUser.id, amount: 250000, category: .gambling, merchant: "CasinoRoyale Online", status: .blocked),
        Transaction(userID: beneficiaryUser.id, amount: 2100, category: .food, merchant: "Rappi"),
        Transaction(userID: beneficiaryUser.id, amount: 1200, category: .transport, merchant: "Uber"),
    ]

    static let spendingByCategory: [TransactionCategory: Double] = [
        .food:          8500,
        .transport:     3200,
        .entertainment: 4800,
        .education:     2100,
        .gambling:      15000,  // ← bajalo para ver el chart balanceado
        .services:      1500
    ]

    static let savingsGoals: [SavingsGoal] = [
        SavingsGoal(
            title: "Zapatillas Nike",
            targetAmount: 35000,
            currentAmount: 12000,
            emoji: "👟"
        ),
        SavingsGoal(
            title: "Auriculares",
            targetAmount: 50000,
            currentAmount: 50000,
            emoji: "🎧",
            isCompleted: true
        ),
        SavingsGoal(
            title: "Viaje con amigos",
            targetAmount: 150000,
            currentAmount: 8000,
            emoji: "✈️"
        )
    ]

    static let qrMerchant = QRMerchantData(
        merchantID: "merchant-001",
        merchantName: "Farmacia Del Pueblo",
        category: .health,
        defaultAmount: nil
    )

    static let alertHistory: [RiskAlert] = [
        RiskAlert(
            transactionID: UUID(),
            beneficiaryID: beneficiaryUser.id,
            benefactorID: benefactorUser.id,
            amount: 15000,
            merchant: "BetAR Online",
            category: .gambling,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            status: .denied,
            resolvedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            educationalTip: "Las apuestas tienen una tasa de pérdida del 97%."
        ),
        RiskAlert(
            transactionID: UUID(),
            beneficiaryID: beneficiaryUser.id,
            benefactorID: benefactorUser.id,
            amount: 50000,
            merchant: "CryptoFast",
            category: .highRiskInvest,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            status: .approved,
            resolvedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            educationalTip: "Las inversiones de alto riesgo pueden generar grandes pérdidas."
        ),
        RiskAlert(
            transactionID: UUID(),
            beneficiaryID: beneficiaryUser.id,
            benefactorID: benefactorUser.id,
            amount: 8000,
            merchant: "Casino Virtual",
            category: .gambling,
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            status: .denied,
            resolvedAt: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            educationalTip: "Ese dinero equivale a 10 días de transporte."
        )
    ]
}
