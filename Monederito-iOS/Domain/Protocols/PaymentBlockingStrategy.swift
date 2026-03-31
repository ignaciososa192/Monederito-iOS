//
//  PaymentBlockingStrategy.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

protocol PaymentBlockingStrategy {
    func shouldBlockTransaction(transaction: Transaction, userProgress: UserProgress) -> BlockingDecision
}
