//
//  WalletCardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

// Tarjeta principal de la billetera del beneficiario
// Muestra saldo disponible y límites configurados por el benefactor

struct WalletCardView: View {
    
    let user: User
    let account: BeneficiaryAccount
    
    // CONCEPTO: @State local para toggle de saldo visible/oculto
    @State private var isBalanceVisible: Bool = true
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.monederitoOrange, Color.monederitoPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mi Billetera")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(user.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Toggle visibilidad del saldo
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isBalanceVisible.toggle()
                        }
                    } label: {
                        Image(systemName: isBalanceVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title3)
                    }
                }
                
                // Saldo disponible
                VStack(alignment: .leading, spacing: 4) {
                    Text("Disponible hoy")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // CONCEPTO: ternario con animación
                    Text(isBalanceVisible ? formatAmount(account.dailyLimit) : "$ ••••••")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .contentTransition(.numericText()) // animación al cambiar
                }
                
                // Límites
                HStack(spacing: 0) {
                    limitView(
                        title: "Límite diario",
                        amount: account.dailyLimit
                    )
                    
                    Divider()
                        .background(.white.opacity(0.3))
                        .frame(height: 30)
                        .padding(.horizontal, 16)
                    
                    limitView(
                        title: "Límite mensual",
                        amount: account.monthlyLimit
                    )
                    
                    Spacer()
                }
            }
            .padding(20)
        }
        .frame(height: 180)
        .shadow(color: Color.monederitoOrange.opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    @ViewBuilder
    private func limitView(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Text(isBalanceVisible ? formatAmount(amount) : "••••")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
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
