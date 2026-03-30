//
//  OperationSuccessView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

// Vista de éxito reutilizable para TODAS las operaciones
// Un solo componente que sirve para transferencia, recarga, pago de servicio, etc.

struct OperationSuccessView: View {
    
    let message: String
    let amount: Double
    let onDone: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            // Ícono animado
            ZStack {
                Circle()
                    .fill(Color.safeGreen.opacity(0.12))
                    .frame(width: 140, height: 140)
                    .scaleEffect(appeared ? 1 : 0.5)
                
                Circle()
                    .fill(Color.safeGreen.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(appeared ? 1 : 0.5)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.safeGreen)
                    .scaleEffect(appeared ? 1 : 0.3)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
            
            VStack(spacing: 12) {
                Text("¡Listo!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                if amount > 0 {
                    Text(formatAmount(amount))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.safeGreen)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.4).delay(0.3), value: appeared)
            
            Spacer()
            
            // Comprobante + Listo
            VStack(spacing: 12) {
                Button {
                    // Paso 13: generar PDF del comprobante
                } label: {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Descargar comprobante")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.safeGreen.opacity(0.1))
                    .foregroundColor(Color.safeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button(action: onDone) {
                    Text("Volver al inicio")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.safeGreen)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.4).delay(0.5), value: appeared)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .onAppear { appeared = true }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        NumberFormatter.argentinePesos.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
