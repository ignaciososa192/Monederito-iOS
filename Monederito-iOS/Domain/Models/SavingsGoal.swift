//
//  SavingsGoal.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

// Modelo de meta de ahorro gamificada
// Viene del MVP del PDF: "Módulo de metas de ahorro gamificado"

struct SavingsGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var emoji: String
    var deadline: Date?
    var isCompleted: Bool
    
    // CONCEPTO: computed property con lógica de negocio
    var progressRatio: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var progressPercentage: Int {
        Int(progressRatio * 100)
    }
    
    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }
    
    var formattedTarget: String { formatAmount(targetAmount) }
    var formattedCurrent: String { formatAmount(currentAmount) }
    var formattedRemaining: String { formatAmount(remainingAmount) }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        emoji: String = "🎯",
        deadline: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.emoji = emoji
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
}
