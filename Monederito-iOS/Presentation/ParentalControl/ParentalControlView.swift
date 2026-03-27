//
//  ParentalControlView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct ParentalControlView: View {
    
    @Environment(AppState.self) private var appState
    @State private var viewModel = ParentalControlViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if viewModel.beneficiaryAccounts.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    // Lista de beneficiarios
                    ForEach($viewModel.beneficiaryAccounts) { $account in
                        
                        // CONCEPTO: navigationDestination
                        // Navegación programática tipada con el enum de rutas.
                        // NavigationLink con value en lugar de destination.
                        NavigationLink {
                            BeneficiaryDetailView(
                                account: $account,
                                onUpdateLimits: { daily, monthly in
                                    Task {
                                        await viewModel.updateDailyLimit(daily, for: account)
                                        await viewModel.updateMonthlyLimit(monthly, for: account)
                                    }
                                },
                                onToggleCategory: { category, blocked in
                                    Task {
                                        await viewModel.toggleCategory(category, blocked: blocked, for: account)
                                    }
                                },
                                onToggleActive: {
                                    Task {
                                        await viewModel.toggleAccount(account)
                                    }
                                }
                            )
                        } label: {
                            beneficiaryRow(account: account)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Botón agregar beneficiario
                    Button {
                        // Paso 7: implementar flujo de invitación
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Agregar beneficiario")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color.monederitoOrange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.monederitoOrange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Control Parental")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let userID = appState.currentUser?.id {
                await viewModel.loadAccounts(for: userID)
            }
        }
        // Toast de éxito
        .overlay(alignment: .top) {
            if let message = viewModel.successMessage {
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.safeGreen)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.4), value: viewModel.successMessage)
            }
        }
    }
    
    @ViewBuilder
    private func beneficiaryRow(account: BeneficiaryAccount) -> some View {
        HStack(spacing: 14) {
            
            ZStack {
                Circle()
                    .fill(Color.monederitoOrange.opacity(0.15))
                    .frame(width: 52, height: 52)
                Text(account.nickname.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.monederitoOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.nickname)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    // Estado
                    HStack(spacing: 4) {
                        Circle()
                            .fill(account.isActive ? Color.safeGreen : Color.gray)
                            .frame(width: 6, height: 6)
                        Text(account.isActive ? "Activa" : "Pausada")
                            .font(.caption)
                            .foregroundColor(account.isActive ? Color.safeGreen : .gray)
                    }
                    
                    Text("·")
                        .foregroundColor(.gray)
                    
                    // Límite diario
                    Text("$\(Int(account.dailyLimit / 1000))k/día")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Categorías bloqueadas
                    if !account.blockedCategories.isEmpty {
                        Text("·")
                            .foregroundColor(.gray)
                        Text("\(account.blockedCategories.count) bloqueadas")
                            .font(.caption)
                            .foregroundColor(Color.riskRed)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(Color.monederitoOrange.opacity(0.5))
            Text("Sin beneficiarios aún")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Text("Agregá a tu hijo o familiar para comenzar a gestionar sus gastos")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
