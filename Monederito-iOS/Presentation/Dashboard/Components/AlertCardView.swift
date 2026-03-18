//
//  AlertCardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

// Tarjeta que muestra una alerta de gasto riesgoso.
// Es el componente MÁS CRÍTICO de la app según el Task Flow del PDF.
// Elena debe poder aprobar o denegar con UN TAP desde esta tarjeta.

struct AlertCardView: View {
    
    let alert: RiskAlert
    
    // CONCEPTO: closure como parámetro
    // Le pasamos qué hacer al aprobar/denegar desde afuera.
    // Esto hace el componente reutilizable y testeable.
    let onApprove: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.riskRed.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text(alert.category.emoji)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("⚠️ Gasto de Riesgo")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.riskRed)
                        
                        if alert.isUrgent {
                            Text("URGENTE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.riskRed)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(alert.merchant)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text(alert.formattedAmount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.riskRed)
            }
            
            HStack(spacing: 6) {
                Text(alert.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.riskRed.opacity(0.1))
                    .foregroundStyle(Color.riskRed)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(alert.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color.warningAmber)
                        .font(.caption)
                    Text("Tip educativo")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.warningAmber)
                }
                
                Text(alert.educationalTip)
                    .font(.caption)
                    .foregroundStyle(Color.monederitoPurple)
                    .fixedSize(horizontal: false, vertical: true) // <- clave
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
            .background(Color.warningAmber.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Botones de acción — el corazón del Task Flow
            HStack(spacing: 12) {
                
                // DENEGAR — acción principal (más prominente)
                Button(action: onDeny) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Denegar")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.riskRed)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // APROBAR
                Button(action: onApprove) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Aprobar")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.safeGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.riskRed.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.riskRed.opacity(0.3), lineWidth: 1)
        )
    }
}

