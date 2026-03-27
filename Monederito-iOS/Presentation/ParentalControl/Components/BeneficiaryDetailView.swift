//
//  BeneficiaryDetailView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct BeneficiaryDetailView: View {
    
    // CONCEPTO: @Binding sobre un elemento de array
    // Modificar este Binding modifica directamente el array
    // en el ViewModel padre — sin necesidad de callbacks.
    @Binding var account: BeneficiaryAccount
    let onUpdateLimits: (Double, Double) -> Void
    let onToggleCategory: (TransactionCategory, Bool) -> Void
    let onToggleActive: () -> Void
    
    @State private var showingLimitConfig: Bool = false
    @State private var showingCategoryConfig: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Header del beneficiario
                headerCard
                
                // Estado de la cuenta
                statusCard
                
                // Límites actuales
                limitsCard
                
                // Categorías bloqueadas
                categoriesCard
                
                // Transacciones recientes de este beneficiario
                recentActivityCard
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle(account.nickname)
        .navigationBarTitleDisplayMode(.large)
        // CONCEPTO: .sheet — presenta una View modal
        .sheet(isPresented: $showingLimitConfig) {
            LimitConfigView(account: $account) { daily, monthly in
                onUpdateLimits(daily, monthly)
            }
        }
        .sheet(isPresented: $showingCategoryConfig) {
            CategoryPermissionView(account: $account) { category, blocked in
                onToggleCategory(category, blocked)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.monederitoOrange, Color.monederitoPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Text(account.nickname.prefix(1).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.nickname)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(account.isActive ? Color.safeGreen : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(account.isActive ? "Cuenta activa" : "Cuenta pausada")
                        .font(.caption)
                        .foregroundColor(account.isActive ? Color.safeGreen : .gray)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estado de la cuenta")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.isActive ? "Cuenta activa" : "Cuenta pausada")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Text(account.isActive
                         ? "Lucas puede realizar gastos normalmente"
                         : "Lucas no puede realizar ningún gasto")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Toggle para activar/desactivar la cuenta
                Toggle("", isOn: Binding(
                    get: { account.isActive },
                    set: { _ in onToggleActive() }
                ))
                .tint(Color.safeGreen)
                .labelsHidden()
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var limitsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Límites de gasto")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button {
                    showingLimitConfig = true
                } label: {
                    Text("Editar")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.monederitoOrange)
                }
            }
            
            HStack(spacing: 0) {
                limitItem(
                    title: "Diario",
                    amount: account.dailyLimit,
                    icon: "sun.max.fill"
                )
                
                Divider().frame(height: 40)
                
                limitItem(
                    title: "Mensual",
                    amount: account.monthlyLimit,
                    icon: "calendar"
                )
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func limitItem(title: String, amount: Double, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(Color.monederitoOrange)
            Text(formatAmount(amount))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var categoriesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Categorías bloqueadas")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button {
                    showingCategoryConfig = true
                } label: {
                    Text("Editar")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.monederitoOrange)
                }
            }
            
            if account.blockedCategories.isEmpty {
                Text("Sin restricciones de categorías")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                // Chips de categorías bloqueadas
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(account.blockedCategories, id: \.self) { category in
                        HStack(spacing: 6) {
                            Text(category.emoji)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.riskRed)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.riskRed.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actividad reciente")
                .font(.headline)
                .foregroundColor(.black)
            
            ForEach(MockData.transactions.prefix(3)) { transaction in
                TransactionRowView(transaction: transaction)
                if transaction.id != MockData.transactions.prefix(3).last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
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
