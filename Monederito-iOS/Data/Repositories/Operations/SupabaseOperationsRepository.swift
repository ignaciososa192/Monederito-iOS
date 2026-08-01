//
//  SupabaseOperationsRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation
import Supabase

final class SupabaseOperationsRepository: OperationsRepositoryProtocol {
    
    private let client: SupabaseClient
    private let transactionRepository: TransactionRepositoryProtocol
    
    init(transactionRepository: TransactionRepositoryProtocol) {
        guard let client = SupabaseConfig.client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
        self.client = client
        self.transactionRepository = transactionRepository
    }
    
    // MARK: - OperationsRepositoryProtocol
    
    func payWithQR(merchantData: QRMerchantData, amount: Double, userID: UUID) async throws -> Transaction {
        
        let transaction = Transaction(
            userID: userID,
            amount: amount,
            category: merchantData.category,
            merchant: merchantData.merchantName
        )
        
        return try await transactionRepository.createTransaction(transaction)
    }
    
    func transfer(to destination: TransferDestination, amount: Double, userID: UUID) async throws -> Transaction {
        
        let transaction = Transaction(
            userID: userID,
            amount: amount,
            category: .services,
            merchant: destination.recipientName
        )
        
        return try await transactionRepository.createTransaction(transaction)
    }
    
    func rechargePhone(number: String, carrier: PhoneCarrier, amount: Double, userID: UUID) async throws -> Transaction {
        
        let transaction = Transaction(
            userID: userID,
            amount: amount,
            category: .services,
            merchant: "Recarga \(carrier.rawValue)"
        )
        
        return try await transactionRepository.createTransaction(transaction)
    }
    
    func rechargeSUBE(cardNumber: String, amount: Double, userID: UUID) async throws -> Transaction {
        
        let transaction = Transaction(
            userID: userID,
            amount: amount,
            category: .transport,
            merchant: "SUBE"
        )
        
        return try await transactionRepository.createTransaction(transaction)
    }
    
    func payService(service: ServiceType, clientNumber: String, amount: Double, userID: UUID) async throws -> Transaction {
        
        let transaction = Transaction(
            userID: userID,
            amount: amount,
            category: .services,
            merchant: service.rawValue
        )
        
        return try await transactionRepository.createTransaction(transaction)
    }
}
