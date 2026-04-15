//
//  SUBERechargeViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 08/04/2026.
//

import Foundation

@Observable
final class SUBERechargeViewModel {
    
    // MARK: - State
    var rechargeState: SUBERechargeState = .idle
    
    // MARK: - SUBE Recharge Form
    var subeCardNumber: String = ""
    var selectedSUBEAmount: Double? = nil
    
    // MARK: - Constants
    let subeAmounts: [Double] = [100, 200, 300, 400, 500, 600, 800, 1000, 1500, 2000]
    
    // MARK: - Computed Properties
    var isSUBECardValid: Bool {
        let cleaned = subeCardNumber.filter { $0.isNumber }
        return cleaned.count == 16
    }
    
    var isRechargeValid: Bool {
        isSUBECardValid && selectedSUBEAmount != nil
    }
    
    var formattedSUBENumber: String {
        let cleaned = subeCardNumber.filter { $0.isNumber }
        if cleaned.count == 16 {
            let groups = [
                String(cleaned.prefix(4)),
                String(cleaned.dropFirst(4).prefix(4)),
                String(cleaned.dropFirst(8).prefix(4)),
                String(cleaned.dropFirst(12).prefix(4))
            ]
            return groups.joined(separator: " ")
        }
        return subeCardNumber
    }
    
    // MARK: - Actions
    func rechargeSUBE(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let amount = selectedSUBEAmount else { return }
        
        rechargeState = .loading
        
        do {
            let transaction = try await repo.rechargeSUBE(
                cardNumber: subeCardNumber,
                amount: amount,
                userID: userID
            )
            rechargeState = .success(transaction)
        } catch let error as AppError {
            rechargeState = .failure(error)
        } catch {
            rechargeState = .failure(.serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func selectAmount(_ amount: Double) {
        selectedSUBEAmount = amount
    }
    
    func reset() {
        rechargeState = .idle
        subeCardNumber = ""
        selectedSUBEAmount = nil
    }
}

// MARK: - SUBE Recharge State
enum SUBERechargeState {
    case idle
    case loading
    case success(Transaction)
    case failure(AppError)
}
