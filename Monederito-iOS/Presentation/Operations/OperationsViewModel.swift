//
//  OperationsViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

// CONCEPTO: enum con associated values para modelar estados de UI
// Cada estado puede llevar datos distintos — muy idiomático en Swift

enum OperationState {
    case idle
    case loading
    case success(message: String, amount: Double)
    case failure(error: AppError)
}

@Observable
class OperationsViewModel {
    
    // MARK: - State
    var operationState: OperationState = .idle
    var recentContacts: [TransferDestination] = []
    
    // MARK: - Transfer form
    var transferAmount: String = ""
    var transferDestination: TransferDestination? = nil
    var cbuCvuInput: String = ""
    var aliasInput: String = ""
    
    // MARK: - Phone recharge
    var phoneNumber: String = ""
    var selectedCarrier: PhoneCarrier? = nil
    var selectedRechargeAmount: Double? = nil
    
    // MARK: - SUBE
    var subeCardNumber: String = ""
    var selectedSUBEAmount: Double? = nil
    
    // MARK: - Services
    var selectedService: ServiceType? = nil
    var selectedProvider: String = ""
    var clientNumber: String = ""
    
    // MARK: - Computed
    var transferAmountDouble: Double {
        Double(transferAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var isTransferValid: Bool {
        transferAmountDouble > 0 && transferDestination != nil
    }
    
    var isCBUValid: Bool {
        let cleaned = cbuCvuInput.filter { $0.isNumber }
        return cleaned.count == 22
    }
    
    // MARK: - Actions
    
    func transfer(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let destination = transferDestination else { return }
        operationState = .loading
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            // En Paso 13: try await repo.transfer(to: destination, amount: transferAmountDouble, userID: userID)
            operationState = .success(
                message: "Transferencia enviada a \(destination.recipientName)",
                amount: transferAmountDouble
            )
        } catch let error as AppError {
            operationState = .failure(error: error)
        } catch {
            operationState = .failure(error: .serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func rechargePhone(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let amount = selectedRechargeAmount,
              let carrier = selectedCarrier else { return }
        operationState = .loading
        
        do {
            try await Task.sleep(nanoseconds: 800_000_000)
            operationState = .success(
                message: "Recarga de \(carrier.rawValue) exitosa a \(phoneNumber)",
                amount: amount
            )
        } catch {
            operationState = .failure(error: .serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func rechargeSUBE(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let amount = selectedSUBEAmount else { return }
        operationState = .loading
        
        do {
            try await Task.sleep(nanoseconds: 800_000_000)
            operationState = .success(
                message: "SUBE recargada exitosamente",
                amount: amount
            )
        } catch {
            operationState = .failure(error: .serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func payService(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let service = selectedService else { return }
        operationState = .loading
        
        do {
            try await Task.sleep(nanoseconds: 800_000_000)
            operationState = .success(
                message: "\(service.rawValue) pagado exitosamente",
                amount: 0
            )
        } catch {
            operationState = .failure(error: .serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func reset() {
        operationState = .idle
        transferAmount = ""
        transferDestination = nil
        cbuCvuInput = ""
        aliasInput = ""
        phoneNumber = ""
        selectedCarrier = nil
        selectedRechargeAmount = nil
        subeCardNumber = ""
        selectedSUBEAmount = nil
        selectedService = nil
        selectedProvider = ""
        clientNumber = ""
    }
    
    // Mock contacts para desarrollo
    func loadRecentContacts() {
        recentContacts = [
            TransferDestination(
                recipientName: "Mamá",
                cbuOrCvu: "0000003100050000000001",
                alias: "mama.monederito",
                isMonederitoUser: true
            ),
            TransferDestination(
                recipientName: "Juan Pérez",
                cbuOrCvu: "0720461088000071507029",
                alias: "juan.perez.mp",
                isMonederitoUser: false
            ),
            TransferDestination(
                recipientName: "Sofia García",
                cbuOrCvu: "0000003100050000000002",
                alias: "sofi.garcia",
                isMonederitoUser: true
            )
        ]
    }
}
