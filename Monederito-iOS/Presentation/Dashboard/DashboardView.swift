//
//  DashboardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    
    // CONCEPTO: @State con clase @Observable
    // El ViewModel vive aquí y SwiftUI lo observa automáticamente.
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                
                // MARK: - Header de bienvenida
                headerSection
                
                // MARK: - Alertas pendientes (prioridad máxima)
                if !viewModel.pendingAlerts.isEmpty {
                    alertsSection
                }
                
                // MARK: - Gráfico de gastos
                SpendingChartView(
                    chartData: viewModel.chartData,
                    total: viewModel.totalMonthlySpending
                )
                .padding(.horizontal)
                
                // MARK: - Beneficiarios
                if !viewModel.beneficiaryAccounts.isEmpty {
                    beneficiariesSection
                }
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Monederito")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Task {
                        await NotificationManager.shared.sendTestRichNotification()
                    }
                } label: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            #endif
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appState.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(Color.monederitoOrange)
                }
            }
        }
        // CONCEPTO: task {} — ejecuta código async cuando la View aparece.
        // Es el reemplazo moderno de onAppear para código asíncrono.
        .task {
            if let userID = appState.currentUser?.id {
                await viewModel.loadDashboard(
                    for: userID,
                    transactionRepo: container.transactionRepository,
                    userRepo: container.userRepository
                )
            }
        }
        // Loading overlay
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color.monederitoOrange)
                        Text("Cargando...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    // CONCEPTO: @ViewBuilder — permite retornar múltiples Views
    // desde una propiedad computada. Mantiene el body limpio.
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, \(appState.currentUser?.fullName.components(separatedBy: " ").first ?? "")! 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !viewModel.pendingAlerts.isEmpty {
                    Text("\(viewModel.pendingAlerts.count) alerta\(viewModel.pendingAlerts.count > 1 ? "s" : "") pendiente\(viewModel.pendingAlerts.count > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundStyle(Color.riskRed)
                        .fontWeight(.medium)
                } else {
                    Text("Todo bajo control ✅")
                        .font(.subheadline)
                        .foregroundStyle(Color.safeGreen)
                }
            }
            Spacer()
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.monederitoOrange.opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(appState.currentUser?.fullName.prefix(1).uppercased() ?? "?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.monederitoOrange)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Alertas de Riesgo", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(Color.riskRed)
                Spacer()
                Text("\(viewModel.pendingAlerts.count) pendiente\(viewModel.pendingAlerts.count > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            ForEach(viewModel.pendingAlerts) { alert in
                AlertCardView(
                    alert: alert,
                    onApprove: {
                        Task {
                            await viewModel.resolveAlert(
                                alert,
                                status: .approved,
                                using: container.transactionRepository
                            )
                        }
                    },
                    onDeny: {
                        Task {
                            await viewModel.resolveAlert(
                                alert,
                                status: .denied,
                                using: container.transactionRepository
                            )
                        }
                    }
                )
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var beneficiariesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis Beneficiarios")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.beneficiaryAccounts) { account in
                BeneficiaryCardView(account: account)
                    .padding(.horizontal)
            }
        }
    }
}
