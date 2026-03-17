//
//  LoginView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

struct LoginView: View {
    
    // CONCEPTO: @Environment — accede a objetos inyectados en el árbol de Views.
    // AppState fue inyectado desde RootView y lo recuperamos así.
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 32) {
            
            // Logo / Header
            VStack(spacing: 12) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.monederitoOrange)
                
                Text("Monederito")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Mucho más que una billetera virtual")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Botones de acceso rápido para desarrollo
            // SOLO para testear — se elimina en producción
            VStack(spacing: 16) {
                Text("Acceso rápido (desarrollo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button {
                    appState.loginAsBenefactor()
                } label: {
                    Label("Entrar como Benefactor (Elena)",
                          systemImage: "person.fill.checkmark")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.monederitoOrange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    appState.loginAsBeneficiary()
                } label: {
                    Label("Entrar como Beneficiario (Lucas)",
                          systemImage: "person.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.monederitoPurple)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
    }
}
