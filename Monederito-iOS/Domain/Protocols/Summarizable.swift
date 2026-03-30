//
//  Summarizable.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation

protocol Summarizable {
    associatedtype Summary
    func makeSummary() -> Summary
}

struct TransactionSummary {
    let totalSpent: Double
    let transactionCount: Int
    let topCategory: TransactionCategory?
    let hasRiskyTransactions: Bool
}

extension Array: Summarizable where Element == Transaction {
    func makeSummary() -> TransactionSummary {
        let total = reduce(0) { $0 + $1.amount }
        let risky = contains { $0.isRisky }
        let categoryTotals = Dictionary(grouping: self, by: \.category)
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        let topCategory = categoryTotals.max(by: { $0.value < $1.value })?.key
        return TransactionSummary(
            totalSpent: total,
            transactionCount: count,
            topCategory: topCategory,
            hasRiskyTransactions: risky
        )
    }
}
