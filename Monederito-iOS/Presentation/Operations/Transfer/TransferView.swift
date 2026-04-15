//
//  TransferView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct TransferView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = TransferViewModel()
    
    @FocusState private var amountFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                // Pantalla de éxito
                if case .success(let transaction) = viewModel.transferState {
                    OperationSuccessView(
                        message: "Transferencia enviada a \(transaction.merchant)",
                        amount: transaction.amount
                    ) {
                        viewModel.reset()
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Monto
                            amountSection
                            
                            // Método de ingreso del destinatario
                            destinationSection
                            
                            // Error
                            if case .failure(let error) = viewModel.transferState {
                                errorBanner(error.errorDescription ?? "Error desconocido")
                            }
                            
                            // Botón transferir
                            transferButton
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("Transferir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color.monederitoOrange)
                }
            }
            .onAppear { viewModel.loadRecentContacts() }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("¿Cuánto querés transferir?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.monederitoOrange)
                
                TextField("0", text: $viewModel.transferAmount)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($amountFocused)
                    .frame(maxWidth: 200)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .onTapGesture { amountFocused = true }
        }
    }
    
    @ViewBuilder
    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("¿A quién transferís?")
                .font(.headline)
                .foregroundColor(.black)
            
            // Selector de método
            Picker("Método", selection: $viewModel.inputMethod) {
                ForEach(InputMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(.segmented)
            
            switch viewModel.inputMethod {
            case .contacts:
                contactsList
            case .cbu:
                cbuInput
            case .alias:
                aliasInput
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var contactsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.recentContacts) { contact in
                Button {
                    withAnimation {
                        viewModel.selectContact(contact)
                    }
                } label: {
                    HStack(spacing: 14) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(contact.isMonederitoUser
                                      ? Color.monederitoOrange.opacity(0.15)
                                      : Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Text(contact.recipientName.prefix(1).uppercased())
                                .fontWeight(.bold)
                                .foregroundColor(contact.isMonederitoUser
                                                 ? Color.monederitoOrange
                                                 : .gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(contact.recipientName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Text(contact.displayIdentifier)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if contact.isMonederitoUser {
                            Text("Monederito")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.monederitoOrange.opacity(0.1))
                                .foregroundColor(Color.monederitoOrange)
                                .clipShape(Capsule())
                        }
                        
                        // Seleccionado
                        if viewModel.transferDestination?.id == contact.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.safeGreen)
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                if contact.id != viewModel.recentContacts.last?.id {
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    private var cbuInput: some View {
        VStack(spacing: 12) {
            AuthTextField(
                title: "CBU / CVU (22 dígitos)",
                icon: "number",
                text: $viewModel.cbuCvuInput,
                keyboardType: .numberPad,
                isValid: viewModel.cbuCvuInput.isEmpty ? nil : viewModel.isCBUValid
            )
            
            if viewModel.isCBUValid {
                Button {
                    viewModel.validateAndSetCBU()
                } label: {
                    Text("Confirmar destinatario")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var aliasInput: some View {
        VStack(spacing: 12) {
            AuthTextField(
                title: "Alias (ej: juan.perez.mp)",
                icon: "at",
                text: $viewModel.aliasInput,
                isValid: viewModel.aliasInput.isEmpty ? nil : viewModel.isAliasValid
            )
            
            if viewModel.isAliasValid {
                Button {
                    viewModel.validateAndSetAlias()
                } label: {
                    Text("Confirmar destinatario")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var transferButton: some View {
        VStack(spacing: 8) {
            
            // Resumen si hay destinatario
            if let dest = viewModel.transferDestination {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.monederitoOrange)
                        .font(.caption)
                    Text("Transferís \(formatAmount(viewModel.transferAmountDouble)) a \(dest.recipientName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(Color.monederitoOrange.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                if dest.isMonederitoUser {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color.safeGreen)
                            .font(.caption)
                        Text("Sin comisión — usuario Monederito")
                            .font(.caption)
                            .foregroundColor(Color.safeGreen)
                    }
                }
            }
            
            Button {
                Task {
                    await viewModel.transfer(
                        userID: appState.currentUser?.id ?? UUID(),
                        using: container.operationsRepository
                    )
                }
            } label: {
                HStack {
                    if case .loading = viewModel.transferState {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Transferir ahora")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isTransferValid
                             ? Color.monederitoOrange
                             : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.isTransferValid)
        }
    }
    
    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color.riskRed)
            Text(message)
                .font(.caption)
                .foregroundColor(Color.riskRed)
        }
        .padding(12)
        .background(Color.riskRed.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func formatAmount(_ amount: Double) -> String {
        NumberFormatter.argentinePesos.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
