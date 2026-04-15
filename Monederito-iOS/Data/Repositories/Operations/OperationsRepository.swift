//
//  OperationsRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation

final class MockOperationsRepository: OperationsRepositoryProtocol {
    
    private func delay() async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
    }
    
    func payWithQR(merchantData: QRMerchantData, amount: Double, userID: UUID) async throws -> Transaction {
        try await delay()
        if merchantData.category.isRisky {
            throw AppError.transactionBlocked(reason: "Categoría de riesgo")
        }
        return Transaction(userID: userID, amount: amount, category: merchantData.category, merchant: merchantData.merchantName)
    }
    
    func transfer(to destination: TransferDestination, amount: Double, userID: UUID) async throws -> Transaction {
        try await delay()
        guard amount > 0 else { throw AppError.insufficientFunds }
        return Transaction(userID: userID, amount: amount, category: .services, merchant: destination.recipientName)
    }
    
    func rechargePhone(number: String, carrier: PhoneCarrier, amount: Double, userID: UUID) async throws -> Transaction {
        try await delay()
        return Transaction(userID: userID, amount: amount, category: .services, merchant: "Recarga \(carrier.rawValue)")
    }
    
    func rechargeSUBE(cardNumber: String, amount: Double, userID: UUID) async throws -> Transaction {
        try await delay()
        return Transaction(userID: userID, amount: amount, category: .transport, merchant: "SUBE")
    }
    
    func payService(service: ServiceType, clientNumber: String, amount: Double, userID: UUID) async throws -> Transaction {
        try await delay()
        return Transaction(userID: userID, amount: amount, category: .services, merchant: service.rawValue)
    }
}
