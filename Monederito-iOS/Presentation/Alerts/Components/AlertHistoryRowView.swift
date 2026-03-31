//
//  AlertHistoryRowView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct AlertHistoryRowView: View {
    
    let alert: RiskAlert
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Ícono con estado
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Text(alert.category.emoji)
                    .font(.title3)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.merchant)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                HStack(spacing: 6) {
                    Text(alert.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("·")
                        .foregroundColor(.gray)
                    
                    Text(alert.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Monto + estado
            VStack(alignment: .trailing, spacing: 4) {
                Text(alert.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                
                statusBadge
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch alert.status {
        case .pending:  return Color.warningAmber
        case .approved: return Color.safeGreen
        case .denied:   return Color.riskRed
        case .expired:  return Color.gray
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(alert.status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }
    
    private var statusIcon: String {
        switch alert.status {
        case .pending:  return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .denied:   return "xmark.circle.fill"
        case .expired:  return "exclamationmark.circle.fill"
        }
    }
}
