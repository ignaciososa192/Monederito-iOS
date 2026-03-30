//
//  QuickActionsView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

// Grilla de accesos rápidos que aparece en el dashboard del beneficiario
// CONCEPTO: callback closures para comunicar acciones al padre

struct QuickActionsView: View {
    
    let onQR: () -> Void
    let onTransfer: () -> Void
    let onPhoneRecharge: () -> Void
    let onSUBE: () -> Void
    let onServices: () -> Void
    
    private let actions: [(icon: String, label: String, color: Color, action: () -> Void)]
    
    init(onQR: @escaping () -> Void,
         onTransfer: @escaping () -> Void,
         onPhoneRecharge: @escaping () -> Void,
         onSUBE: @escaping () -> Void,
         onServices: @escaping () -> Void) {
        self.onQR = onQR
        self.onTransfer = onTransfer
        self.onPhoneRecharge = onPhoneRecharge
        self.onSUBE = onSUBE
        self.onServices = onServices
        
        self.actions = [
            ("qrcode.viewfinder", "Pagar QR", Color.monederitoOrange, onQR),
            ("arrow.right.arrow.left", "Transferir", Color.monederitoPurple, onTransfer),
            ("phone.fill", "Recargar cel.", Color.safeGreen, onPhoneRecharge),
            ("tram.fill", "SUBE", Color.warningAmber, onSUBE),
            ("bolt.fill", "Servicios", Color(hex: "#E91E8C"), onServices)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Operaciones")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(actions.indices, id: \.self) { index in
                        let action = actions[index]
                        actionButton(
                            icon: action.icon,
                            label: action.label,
                            color: action.color,
                            onTap: action.action
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(icon: String, label: String, color: Color, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
}
