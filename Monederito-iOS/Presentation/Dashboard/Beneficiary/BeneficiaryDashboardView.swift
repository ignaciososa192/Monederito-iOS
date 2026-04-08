//
//  BeneficiaryDashboardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct BeneficiaryDashboardView: View {
    
    @Environment(AppState.self) private var appState
    @State private var viewModel = BeneficiaryDashboardViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                
                // Wallet Card
                if let user = appState.currentUser,
                   let account = viewModel.beneficiaryAccount {
                    WalletCardView(user: user, account: account)
                        .padding(.horizontal)
                }
                
                // Quick Actions - Navigation to Operations
                quickActionsSection
                
                // Resumen del mes
                if let summary = viewModel.summary {
                    summarySection(summary)
                }
                
                // Metas de ahorro
                if !viewModel.activeGoals.isEmpty {
                    goalsSection
                }
                
                // Transacciones recientes
                transactionsSection
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Mi Billetera")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let userID = appState.currentUser?.id {
                await viewModel.loadData(for: userID)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                        .tint(Color.monederitoPurple)
                        .padding(24)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    @ViewBuilder
    private var quickActionsSection: some View {
        QuickActionsView(
            onQR: {
                // Navigate to Operations tab with QR selected
                navigateToOperation(.qr)
            },
            onTransfer: {
                // Navigate to Operations tab with Transfer selected
                navigateToOperation(.transfer)
            },
            onPhoneRecharge: {
                // Navigate to Operations tab with Phone Recharge selected
                navigateToOperation(.phoneRecharge)
            },
            onSUBE: {
                // Navigate to Operations tab with SUBE Recharge selected
                navigateToOperation(.subeRecharge)
            },
            onServices: {
                // Navigate to Operations tab with Services selected
                navigateToOperation(.services)
            }
        )
    }
    
    private func navigateToOperation(_ operation: OperationsMainView.OperationType) {
        appState.pendingOperation = operation
        appState.selectedBeneficiaryTab = .operations
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func summarySection(_ summary: TransactionSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Este mes")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                summaryCard(
                    title: "Gastos",
                    value: formatAmount(summary.totalSpent),
                    icon: "arrow.up.circle.fill",
                    color: summary.hasRiskyTransactions ? Color.riskRed : Color.monederitoOrange
                )
                
                summaryCard(
                    title: "Movimientos",
                    value: "\(summary.transactionCount)",
                    icon: "list.bullet.circle.fill",
                    color: Color.monederitoPurple
                )
                
                if let top = summary.topCategory {
                    summaryCard(
                        title: "Mayor gasto",
                        value: top.emoji,
                        icon: "chart.bar.fill",
                        color: Color.safeGreen
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mis Metas 🎯")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.completedGoals.count)/\(viewModel.savingsGoals.count) completadas")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            ForEach(viewModel.activeGoals) { goal in
                SavingsGoalCardView(goal: goal)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Últimos movimientos")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(viewModel.recentTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    
                    if transaction.id != viewModel.recentTransactions.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .padding(.horizontal)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
