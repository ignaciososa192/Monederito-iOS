//
//  TransferViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 08/04/2026.
//

import Foundation

@Observable
final class TransferViewModel {
    
    // MARK: - State
    var transferState: TransferState = .idle
    var recentContacts: [TransferDestination] = []
    
    // MARK: - Transfer Form
    var transferAmount: String = ""
    var transferDestination: TransferDestination? = nil
    var cbuCvuInput: String = ""
    var aliasInput: String = ""
    var inputMethod: InputMethod = .contacts
    
    // MARK: - Computed Properties
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
    
    var isAliasValid: Bool {
        let cleaned = aliasInput.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "." }
        return cleaned.count >= 6 && cleaned.count <= 20 && cleaned.contains(".")
    }
    
    // MARK: - Actions
    func transfer(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let destination = transferDestination else { return }
        transferState = .loading
        
        do {
            let transaction = try await repo.transfer(to: destination, amount: transferAmountDouble, userID: userID)
            transferState = .success(transaction)
        } catch let error as AppError {
            transferState = .failure(error)
        } catch {
            transferState = .failure(.serverError(code: 0, message: error.localizedDescription))
        }
    }
    
    func selectContact(_ contact: TransferDestination) {
        transferDestination = contact
        inputMethod = .contacts
    }
    
    func validateAndSetCBU() {
        if isCBUValid {
            let cleaned = cbuCvuInput.filter { $0.isNumber }
            transferDestination = TransferDestination(
                recipientName: "CBU/CVU",
                cbuOrCvu: cleaned,
                alias: nil,
                isMonederitoUser: false
            )
            inputMethod = .cbu
        }
    }
    
    func validateAndSetAlias() {
        if isAliasValid {
            transferDestination = TransferDestination(
                recipientName: "Alias",
                cbuOrCvu: "",
                alias: aliasInput.lowercased(),
                isMonederitoUser: false
            )
            inputMethod = .alias
        }
    }
    
    func reset() {
        transferState = .idle
        transferAmount = ""
        transferDestination = nil
        cbuCvuInput = ""
        aliasInput = ""
        inputMethod = .contacts
    }
    
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

// MARK: - Transfer State
enum TransferState {
    case idle
    case loading
    case success(Transaction)
    case failure(AppError)
}

// MARK: - Input Method
enum InputMethod: String, CaseIterable {
    case contacts = "Contactos"
    case cbu = "CBU / CVU"
    case alias = "Alias"
}
