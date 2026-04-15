//
//  QRPaymentViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 08/04/2026.
//

import Foundation

@Observable
final class QRPaymentViewModel {
    
    // MARK: - State
    var paymentState: QRPaymentState = .idle
    var isScanning: Bool = false
    
    // MARK: - QR Payment Form
    var scannedMerchantData: QRMerchantData? = nil
    var paymentAmount: String = ""
    
    // MARK: - Computed Properties
    var paymentAmountDouble: Double {
        Double(paymentAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var isPaymentValid: Bool {
        scannedMerchantData != nil && paymentAmountDouble > 0
    }
    
    var isAmountValid: Bool {
        paymentAmountDouble > 0 && paymentAmountDouble <= 500000 // Limit for QR payments
    }
    
    // MARK: - Actions
    func processQRPayment(userID: UUID, using repo: any OperationsRepositoryProtocol) async {
        guard let merchantData = scannedMerchantData else { return }
        
        paymentState = .loading
        
        do {
            let transaction = try await repo.payWithQR(
                merchantData: merchantData,
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
    
    func simulateQRScan() {
        // Mock QR data for development and testing
        scannedMerchantData = QRMerchantData(
            merchantID: "merchant-001",
            merchantName: "Farmacia Del Pueblo",
            category: .health,
            defaultAmount: nil
        )
        isScanning = false
    }
    
    func startScanning() {
        isScanning = true
        // In a real implementation, this would open the camera
        // For now, we'll simulate after a delay
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                simulateQRScan()
            }
        }
    }
    
    func cancelScanning() {
        isScanning = false
        scannedMerchantData = nil
    }
    
    func reset() {
        paymentState = .idle
        scannedMerchantData = nil
        paymentAmount = ""
        isScanning = false
    }
    
    func clearMerchantData() {
        scannedMerchantData = nil
    }
}

// MARK: - QR Payment State
enum QRPaymentState {
    case idle
    case scanning
    case loading
    case success(Transaction)
    case failure(AppError)
}
