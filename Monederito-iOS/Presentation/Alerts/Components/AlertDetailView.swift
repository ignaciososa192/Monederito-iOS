//
//  AlertDetailView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct AlertDetailView: View {
    
    let alert: RiskAlert
    let onApprove: (() -> Void)?
    let onDeny: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header con estado visual
                    headerCard
                    
                    // Detalles de la transacción
                    detailsCard
                    
                    // Tip educativo
                    educationalCard
                    
                    // Botones si está pendiente
                    if alert.status.isPending {
                        actionButtons
                    } else {
                        resolvedInfo
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color.monederitoBackground.ignoresSafeArea())
            .navigationTitle("Detalle de Alerta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerCard: some View {
        VStack(spacing: 16) {
            
            // Ícono grande
            ZStack {
                Circle()
                    .fill(alert.status.isPending
                          ? Color.riskRed.opacity(0.12)
                          : statusColor.opacity(0.12))
                    .frame(width: 90, height: 90)
                
                Text(alert.category.emoji)
                    .font(.system(size: 44))
            }
            
            VStack(spacing: 6) {
                Text(alert.merchant)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(alert.formattedAmount)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(alert.status.isPending ? Color.riskRed : statusColor)
                
                // Badge de estado
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                    Text(alert.status.rawValue)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(statusColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.1))
                .clipShape(Capsule())
                
                if alert.isUrgent {
                    Text("⚠️ URGENTE — lleva más de 3 minutos sin resolver")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.riskRed)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Detalles")
                .font(.headline)
                .foregroundColor(.black)
            
            detailRow(icon: "tag.fill", label: "Categoría", value: "\(alert.category.emoji) \(alert.category.rawValue)")
            Divider()
            detailRow(icon: "clock.fill", label: "Fecha y hora", value: alert.createdAt.formatted(.dateTime.day().month().hour().minute()))
            Divider()
            detailRow(icon: "person.fill", label: "Solicitado por", value: "Lucas García")
            
            if let resolvedAt = alert.resolvedAt {
                Divider()
                detailRow(icon: "checkmark.circle.fill", label: "Resuelto", value: resolvedAt.formatted(.relative(presentation: .named)))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var educationalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.warningAmber)
                Text("Tip educativo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.warningAmber)
            }
            
            Text(alert.educationalTip)
                .font(.subheadline)
                .foregroundColor(Color.monederitoPurple)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.warningAmber.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onDeny?()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Denegar operación")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.riskRed)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button {
                onApprove?()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Aprobar operación")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.safeGreen)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    @ViewBuilder
    private var resolvedInfo: some View {
        HStack(spacing: 10) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text("Esta alerta fue \(alert.status.rawValue.lowercased())")
                .font(.subheadline)
                .foregroundColor(statusColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(statusColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    @ViewBuilder
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.monederitoOrange)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var statusColor: Color {
        switch alert.status {
        case .pending:  return Color.warningAmber
        case .approved: return Color.safeGreen
        case .denied:   return Color.riskRed
        case .expired:  return Color.gray
        }
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
