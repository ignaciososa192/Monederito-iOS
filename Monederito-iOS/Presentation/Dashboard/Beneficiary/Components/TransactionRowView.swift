//
//  TransactionRowView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct TransactionRowView: View {
    
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Ícono de categoría
            ZStack {
                Circle()
                    .fill(transaction.isRisky
                          ? Color.riskRed.opacity(0.12)
                          : Color.monederitoOrange.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Text(transaction.category.emoji)
                    .font(.title3)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchant)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Monto y estado
            VStack(alignment: .trailing, spacing: 3) {
                Text("- \(transaction.formattedAmount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        transaction.status == .blocked
                        ? .gray
                        : (transaction.isRisky ? Color.riskRed : .black)
                    )
                
                // Badge de estado
                statusBadge
            }
        }
        .padding(.vertical, 4)
        // Tachado si está bloqueada
        .opacity(transaction.status == .blocked ? 0.6 : 1.0)
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch transaction.status {
        case .blocked:
            Text("Bloqueado")
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.riskRed.opacity(0.1))
                .foregroundColor(Color.riskRed)
                .clipShape(Capsule())
        case .pending:
            Text("Pendiente")
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.warningAmber.opacity(0.15))
                .foregroundColor(Color.warningAmber)
                .clipShape(Capsule())
        case .completed:
            Text(transaction.date.formatted(.dateTime.day().month()))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}
