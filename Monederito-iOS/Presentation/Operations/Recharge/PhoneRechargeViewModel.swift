//
//  PhoneRechargeViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 08/04/2026.
//

import Foundation

@Observable
final class PhoneRechargeViewModel {
    
    // MARK: - State
    var rechargeState: PhoneRechargeState = .idle
    
    // MARK: - Phone Recharge Form
    var phoneNumber: String = ""
    var selectedCarrier: PhoneCarrier? = nil
    var selectedRechargeAmount: Double? = nil
    
    // MARK: - Constants
    let availableCarriers: [PhoneCarrier] = [.personal, .claro, .movistar]
    let rechargeAmounts: [Double] = [100, 200, 300, 500, 750, 1000, 1500, 2000]
    
    // MARK: - Computed Properties
    var isPhoneNumberValid: Bool {
        let cleaned = phoneNumber.filter { $0.isNumber }
        return cleaned.count == 10 && cleaned.hasPrefix("11")
    }
    
    var isRechargeValid: Bool {
        isPhoneNumberValid && selectedCarrier != nil && selectedRechargeAmount != nil
    }
    
    var formattedPhoneNumber: String {
        let cleaned = phoneNumber.filter { $0.isNumber }
        if cleaned.count == 10 {
            let areaCode = String(cleaned.prefix(2))
            let prefix = String(cleaned.dropFirst(2).prefix(4))
            let suffix = String(cleaned.dropFirst(6))
            return "(\(areaCode)) \(prefix)-\(suffix)"
        }
        return phoneNumber
    }
    
    // MARK: - Actions
    func rechargePhone(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let amount = selectedRechargeAmount,
              let carrier = selectedCarrier else { return }
        
        rechargeState = .loading
        
        do {
            let transaction = try await repo.rechargePhone(
                number: phoneNumber,
                carrier: carrier,
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
    
    func selectCarrier(_ carrier: PhoneCarrier) {
        selectedCarrier = carrier
    }
    
    func selectAmount(_ amount: Double) {
        selectedRechargeAmount = amount
    }
    
    func reset() {
        rechargeState = .idle
        phoneNumber = ""
        selectedCarrier = nil
        selectedRechargeAmount = nil
    }
}

// MARK: - Phone Recharge State
enum PhoneRechargeState {
    case idle
    case loading
    case success(Transaction)
    case failure(AppError)
}
