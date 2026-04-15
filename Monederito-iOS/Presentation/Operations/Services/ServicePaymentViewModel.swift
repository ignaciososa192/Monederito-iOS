//
//  ServicePaymentViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 08/04/2026.
//

import Foundation

@Observable
final class ServicePaymentViewModel {
    
    // MARK: - State
    var paymentState: ServicePaymentState = .idle
    
    // MARK: - Service Payment Form
    var selectedService: ServiceType? = nil
    var selectedProvider: String = ""
    var clientNumber: String = ""
    var paymentAmount: String = ""
    
    // MARK: - Constants
    let availableServices: [ServiceType] = [.electricity, .water, .gas, .internet]
    let commonProviders: [String: [String]] = [
        "Luz": ["Edesur", "Edenor", "EPE", "EPEC"],
        "Agua": ["AySA", "Aguas Bonaerenses", "Cooperativa Agua"],
        "Gas": ["Metrogas", "Gas Natural Fenosa", "Litoral Gas"],
        "Internet / TV": ["Fibertel", "Telecentro", "Personal Flow", "Claro"],
        "Telefonía": ["Claro", "Personal", "Movistar"]
    ]
    
    // MARK: - Computed Properties
    var isClientNumberValid: Bool {
        let cleaned = clientNumber.filter { $0.isNumber }
        return cleaned.count >= 6 && cleaned.count <= 12
    }
    
    var isPaymentAmountValid: Bool {
        let amount = Double(paymentAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
        return amount > 0 && amount <= 999999
    }
    
    var paymentAmountDouble: Double {
        Double(paymentAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var isPaymentValid: Bool {
        selectedService != nil && !selectedProvider.isEmpty && isClientNumberValid && isPaymentAmountValid
    }
    
    var availableProviders: [String] {
        guard let service = selectedService else { return [] }
        return commonProviders[service.rawValue] ?? []
    }
    
    // MARK: - Actions
    func payService(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let service = selectedService else { return }
        
        paymentState = .loading
        
        do {
            let transaction = try await repo.payService(
                service: service,
                clientNumber: clientNumber,
                amount: paymentAmountDouble,
                userID: userID
            )
            paymentState = .success(transaction)
        } catch let error as AppError {
            paymentState = .failure(error)
        } catch {
            paymentState = .failure(.serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func selectService(_ service: ServiceType) {
        selectedService = service
        // Clear provider when service changes to avoid mismatch
        selectedProvider = ""
    }
    
    func selectProvider(_ provider: String) {
        selectedProvider = provider
    }
    
    func reset() {
        paymentState = .idle
        selectedService = nil
        selectedProvider = ""
        clientNumber = ""
        paymentAmount = ""
    }
}

// MARK: - Service Payment State
enum ServicePaymentState {
    case idle
    case loading
    case success(Transaction)
    case failure(AppError)
}
