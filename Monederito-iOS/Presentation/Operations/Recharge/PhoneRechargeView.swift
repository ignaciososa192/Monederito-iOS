//
//  PhoneRechargeView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct PhoneRechargeView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = OperationsViewModel()
    
    private let presetAmounts: [Double] = [200, 500, 1000, 2000, 5000]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                if case .success(let message, let amount) = viewModel.operationState {
                    OperationSuccessView(message: message, amount: amount) {
                        viewModel.reset()
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // Número de teléfono
                            phoneSection
                            
                            // Selección de compañía
                            if !viewModel.phoneNumber.isEmpty {
                                carrierSection
                            }
                            
                            // Monto
                            if viewModel.selectedCarrier != nil {
                                amountSection
                            }
                            
                            // Botón
                            if viewModel.selectedRechargeAmount != nil {
                                rechargeButton
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.phoneNumber.isEmpty)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedCarrier == nil)
                    }
                }
            }
            .navigationTitle("Recargar celular")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Número a recargar")
                .font(.headline)
                .foregroundColor(.black)
            
            AuthTextField(
                title: "Número de celular",
                icon: "phone.fill",
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad,
                isValid: viewModel.phoneNumber.isEmpty ? nil
                    : viewModel.phoneNumber.filter { $0.isNumber }.count >= 10
            )
            
            // Acceso rápido — mi número
            Button {
                viewModel.phoneNumber = "1134567890"
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text("Usar mi número")
                        .font(.caption)
                }
                .foregroundColor(Color.monederitoOrange)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var carrierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compañía")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack(spacing: 10) {
                ForEach(PhoneCarrier.allCases) { carrier in
                    Button {
                        withAnimation { viewModel.selectedCarrier = carrier }
                    } label: {
                        VStack(spacing: 6) {
                            Text(carrier.logo)
                                .font(.title2)
                            Text(carrier.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.selectedCarrier == carrier ? .white : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.selectedCarrier == carrier
                            ? Color.monederitoOrange
                            : Color.gray.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monto")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(presetAmounts, id: \.self) { amount in
                    Button {
                        withAnimation { viewModel.selectedRechargeAmount = amount }
                    } label: {
                        Text(formatAmount(amount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.selectedRechargeAmount == amount ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewModel.selectedRechargeAmount == amount
                                ? Color.monederitoOrange
                                : Color.gray.opacity(0.08)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var rechargeButton: some View {
        Button {
            Task {
                await viewModel.rechargePhone(
                    userID: appState.currentUser?.id ?? UUID(),
                    using: container.operationsRepository
                )
            }
        } label: {
            HStack {
                if case .loading = viewModel.operationState {
                    ProgressView().tint(.white).scaleEffect(0.8)
                } else {
                    Image(systemName: "bolt.fill")
                    Text("Recargar ahora")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.safeGreen)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        NumberFormatter.argentinePesos.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
