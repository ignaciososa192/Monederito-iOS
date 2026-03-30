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
    
    @State private var viewModel = OperationsViewModel()
    @State private var simulatedMerchant = MockData.qrMerchant
    @State private var amount: String = ""
    @State private var scanned: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                if case .success(let message, let amountVal) = viewModel.operationState {
                    OperationSuccessView(message: message, amount: amountVal) {
                        viewModel.reset()
                        dismiss()
                    }
                } else if !scanned {
                    scannerSimulation
                } else {
                    paymentConfirmation
                }
            }
            .navigationTitle("Pagar con QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(scanned ? "Atrás" : "Cancelar") {
                        if scanned { scanned = false }
                        else { dismiss() }
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
                withAnimation { scanned = true }
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
                VStack(spacing: 12) {
                    Text(simulatedMerchant.category.emoji)
                        .font(.system(size: 50))
                    
                    Text(simulatedMerchant.merchantName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(simulatedMerchant.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                
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
                        
                        TextField("0", text: $amount)
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
                    let amountDouble = Double(amount) ?? 0
                    Task {
                        viewModel.operationState = .loading
                        try? await Task.sleep(nanoseconds: 800_000_000)
                        viewModel.operationState = .success(
                            message: "Pago a \(simulatedMerchant.merchantName) exitoso",
                            amount: amountDouble
                        )
                    }
                } label: {
                    HStack {
                        if case .loading = viewModel.operationState {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "qrcode")
                            Text("Confirmar pago")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!amount.isEmpty ? Color.monederitoOrange : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(amount.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
}
