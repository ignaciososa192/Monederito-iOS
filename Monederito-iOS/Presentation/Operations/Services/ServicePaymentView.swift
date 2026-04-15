//
//  ServicePaymentView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct ServicePaymentView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ServicePaymentViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                if case .success(let transaction) = viewModel.paymentState {
                    OperationSuccessView(
                        message: "\(transaction.merchant) pagado exitosamente",
                        amount: transaction.amount
                    ) {
                        viewModel.reset()
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            if viewModel.selectedService == nil {
                                serviceGrid
                            } else {
                                serviceDetailForm
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle(viewModel.selectedService?.rawValue ?? "Pagar servicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(viewModel.selectedService == nil ? "Cancelar" : "Atrás") {
                        if viewModel.selectedService == nil {
                            dismiss()
                        } else {
                            withAnimation { viewModel.selectedService = nil }
                        }
                    }
                    .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var serviceGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("¿Qué servicio querés pagar?")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.availableServices) { service in
                    Button {
                        withAnimation { viewModel.selectService(service) }
                    } label: {
                        VStack(spacing: 10) {
                            Text(service.emoji)
                                .font(.largeTitle)
                            Text(service.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var serviceDetailForm: some View {
        if let service = viewModel.selectedService {
            VStack(spacing: 20) {
                
                // Header del servicio
                HStack(spacing: 12) {
                    Text(service.emoji)
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(service.rawValue)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("Ingresá los datos de tu factura")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                
                // Proveedor
                VStack(alignment: .leading, spacing: 12) {
                    Text("Empresa proveedora")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ForEach(viewModel.availableProviders, id: \.self) { provider in
                        Button {
                            withAnimation { viewModel.selectProvider(provider) }
                        } label: {
                            HStack {
                                Text(provider)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                                if viewModel.selectedProvider == provider {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.safeGreen)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                viewModel.selectedProvider == provider
                                ? Color.monederitoOrange.opacity(0.06)
                                : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        if provider != service.providers.last {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                
                // Número de cliente
                if !viewModel.selectedProvider.isEmpty {
                    VStack(spacing: 16) {
                        AuthTextField(
                            title: "Número de cliente",
                            icon: "number",
                            text: $viewModel.clientNumber,
                            keyboardType: .numberPad,
                            isValid: viewModel.clientNumber.isEmpty ? nil : viewModel.isClientNumberValid
                        )
                        
                        AuthTextField(
                            title: "Monto a pagar",
                            icon: "dollarsign.circle",
                            text: $viewModel.paymentAmount,
                            keyboardType: .decimalPad,
                            isValid: viewModel.paymentAmount.isEmpty ? nil : viewModel.isPaymentAmountValid
                        )
                        
                        // Escanear código de barras
                        Button {
                            // Paso 13: integrar AVFoundation para escanear
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "barcode.viewfinder")
                                Text("Escanear código de barras")
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.monederitoOrange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.monederitoOrange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if viewModel.isPaymentValid {
                            Button {
                                Task {
                                    await viewModel.payService(
                                        userID: appState.currentUser?.id ?? UUID(),
                                        using: container.operationsRepository
                                    )
                                }
                            } label: {
                                HStack {
                                    if case .loading = viewModel.paymentState {
                                        ProgressView().tint(.white).scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "bolt.fill")
                                        Text("Pagar servicio")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.monederitoOrange)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
            }
        }
    }
}

