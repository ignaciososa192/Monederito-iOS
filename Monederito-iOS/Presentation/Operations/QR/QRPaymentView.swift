//
//  QRPaymentView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct QRPaymentView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = QRPaymentViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                if case .success(let transaction) = viewModel.paymentState {
                    OperationSuccessView(
                        message: "Pago a \(transaction.merchant) exitoso",
                        amount: transaction.amount
                    ) {
                        viewModel.reset()
                        dismiss()
                    }
                } else if viewModel.scannedMerchantData == nil {
                    scannerSimulation
                } else {
                    paymentConfirmation
                }
            }
            .navigationTitle("Pagar con QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(viewModel.scannedMerchantData == nil ? "Cancelar" : "Atrás") {
                        if viewModel.scannedMerchantData == nil {
                            dismiss()
                        } else {
                            viewModel.clearMerchantData()
                        }
                    }
                    .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var scannerSimulation: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Simulación de cámara QR
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 280, height: 280)
                
                // Marco del QR
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.monederitoOrange, lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Text("Apuntá la cámara al código QR del comercio")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Simular escaneo para desarrollo
            Button {
                viewModel.startScanning()
            } label: {
                HStack {
                    Image(systemName: "qrcode")
                    Text("Simular escaneo (DEBUG)")
                }
                .font(.subheadline)
                .foregroundColor(Color.monederitoOrange)
                .padding()
                .background(Color.monederitoOrange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var paymentConfirmation: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Info del comercio
                if let merchant = viewModel.scannedMerchantData {
                    VStack(spacing: 12) {
                        Text(merchant.category.emoji)
                            .font(.system(size: 50))
                        
                        Text(merchant.merchantName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text(merchant.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                }
                
                // Monto
                VStack(spacing: 8) {
                    Text("¿Cuánto vas a pagar?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.monederitoOrange)
                        
                        TextField("0", text: $viewModel.paymentAmount)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.black)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                
                // Botón pagar
                Button {
                    Task {
                        await viewModel.processQRPayment(
                            userID: appState.currentUser?.id ?? UUID(),
                            using: container.operationsRepository
                        )
                    }
                } label: {
                    HStack {
                        if case .loading = viewModel.paymentState {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "qrcode")
                            Text("Confirmar pago")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isPaymentValid ? Color.monederitoOrange : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!viewModel.isPaymentValid)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
}
