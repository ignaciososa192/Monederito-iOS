//
//  PrivacyPolicyView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header
                        headerSection
                        
                        // Content sections
                        VStack(alignment: .leading, spacing: 20) {
                            privacySection(
                                title: "Información que recopilamos",
                                content: "Recopilamos información personal como tu nombre, email, teléfono y datos financieros necesarios para operar la plataforma. También recopilamos datos de uso para mejorar nuestros servicios."
                            )
                            
                            privacySection(
                                title: "Cómo usamos tu información",
                                content: "Utilizamos tu información para procesar transacciones, enviar alertas de riesgo, proporcionar soporte técnico y mejorar la seguridad de la plataforma. Nunca vendemos tus datos a terceros."
                            )
                            
                            privacySection(
                                title: "Compartición de datos",
                                content: "Compartimos información únicamente cuando es necesario para procesar transacciones bancarias o cuando así lo exige la ley. Todos nuestros partners están sujetos a estrictos acuerdos de confidencialidad."
                            )
                            
                            privacySection(
                                title: "Seguridad de tus datos",
                                content: "Implementamos encriptación de nivel bancario, autenticación biométrica y monitoreo continuo para proteger tu información. Tus datos se almacenan en servidores seguros con redundancia geográfica."
                            )
                            
                            privacySection(
                                title: "Tus derechos",
                                content: "Tenés derecho a acceder, corregir o eliminar tus datos personales en cualquier momento. También podés exportar tus datos o desactivar tu cuenta permanentemente."
                            )
                            
                            privacySection(
                                title: "Cambios a esta política",
                                content: "Nos reservamos el derecho de actualizar esta política de privacidad. Te notificaremos de cualquier cambio significativo a través de la aplicación o email."
                            )
                        }
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Política de privacidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Última actualización: Abril 2026")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Tu privacidad es nuestra prioridad")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("En Monederito nos comprometemos a proteger tu información personal y a ser transparentes sobre cómo la utilizamos.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
    
    @ViewBuilder
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
    
    @ViewBuilder
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("¿Tenés preguntas?")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Button("Contactá a nuestro equipo de soporte") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundColor(Color.monederitoOrange)
        }
        .padding(.top, 16)
    }
}

#Preview {
    PrivacyPolicyView()
}
