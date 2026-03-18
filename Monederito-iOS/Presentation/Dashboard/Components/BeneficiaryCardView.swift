//
//  BeneficiaryCardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

struct BeneficiaryCardView: View {
    
    let account: BeneficiaryAccount
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.monederitoOrange.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text(account.nickname.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.monederitoOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.nickname)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    
                
                // Barra de progreso del límite mensual
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Límite mensual")
                            .font(.caption2)
                            .foregroundStyle(Color.monederitoPurple)
                        Spacer()
                        Text("\(formatAmount(account.remainingMonthlyBudget)) restantes")
                            .font(.caption2)
                            .foregroundStyle(Color.monederitoPurple)
                    }
                    
                    // CONCEPTO: GeometryReader — accede al tamaño del contenedor
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(
                                    width: geo.size.width * progressRatio,
                                    height: 6
                                )
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    private var progressRatio: Double {
        guard account.monthlyLimit > 0 else { return 0 }
        let spent = account.monthlyLimit - account.remainingMonthlyBudget
        return min(spent / account.monthlyLimit, 1.0)
    }
    
    private var progressColor: Color {
        switch progressRatio {
        case 0..<0.6:  return Color.safeGreen
        case 0.6..<0.85: return Color.warningAmber
        default: return Color.riskRed
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
