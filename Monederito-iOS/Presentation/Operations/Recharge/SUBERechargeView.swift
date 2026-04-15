//
//  SUBERechargeView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct SUBERechargeView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = SUBERechargeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                if case .success(let transaction) = viewModel.rechargeState {
                    OperationSuccessView(
                        message: "SUBE recargada exitosamente",
                        amount: transaction.amount
                    ) {
                        viewModel.reset()
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // Info card
                            HStack(spacing: 12) {
                                Image(systemName: "tram.fill")
                                    .foregroundColor(Color.warningAmber)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Recarga SUBE")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Text("La recarga estará disponible en 72hs al acercar la tarjeta al molinete")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(14)
                            .background(Color.warningAmber.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Número de tarjeta
                            cardNumberSection
                            
                            // Montos
                            if !viewModel.subeCardNumber.isEmpty {
                                amountSection
                            }
                            
                            if viewModel.selectedSUBEAmount != nil {
                                rechargeButton
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("Recargar SUBE")
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
    private var cardNumberSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Número de tarjeta SUBE")
                .font(.headline)
                .foregroundColor(.black)
            
            AuthTextField(
                title: "Número SUBE (16 dígitos)",
                icon: "creditcard.fill",
                text: $viewModel.subeCardNumber,
                keyboardType: .numberPad,
                isValid: viewModel.subeCardNumber.isEmpty ? nil : viewModel.isSUBECardValid
            )
            
            HStack(spacing: 6) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(Color.monederitoPurple)
                Text("O acercá la tarjeta al teléfono para leerla automáticamente (NFC)")
                    .font(.caption)
                    .foregroundColor(.gray)
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
            Text("¿Cuánto cargás?")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(viewModel.subeAmounts, id: \.self) { amount in
                    Button {
                        withAnimation { viewModel.selectAmount(amount) }
                    } label: {
                        Text(formatAmount(amount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.selectedSUBEAmount == amount ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                viewModel.selectedSUBEAmount == amount
                                ? Color.warningAmber
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
                await viewModel.rechargeSUBE(
                    userID: appState.currentUser?.id ?? UUID(),
                    using: container.operationsRepository
                )
            }
        } label: {
            HStack {
                if case .loading = viewModel.rechargeState {
                    ProgressView().tint(.white).scaleEffect(0.8)
                } else {
                    Image(systemName: "tram.fill")
                    Text("Recargar SUBE")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.warningAmber)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        NumberFormatter.argentinePesos.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
