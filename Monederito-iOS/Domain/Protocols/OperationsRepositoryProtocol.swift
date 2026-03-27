//
//  OperationsRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

protocol OperationsRepositoryProtocol: AnyObject {
    func payWithQR(merchantData: QRMerchantData, amount: Double, userID: UUID) async throws -> Transaction
    func transfer(to destination: TransferDestination, amount: Double, userID: UUID) async throws -> Transaction
    func rechargePhone(number: String, carrier: PhoneCarrier, amount: Double, userID: UUID) async throws -> Transaction
    func rechargeSUBE(cardNumber: String, amount: Double, userID: UUID) async throws -> Transaction
    func payService(service: ServiceType, clientNumber: String, userID: UUID) async throws -> Transaction
}
