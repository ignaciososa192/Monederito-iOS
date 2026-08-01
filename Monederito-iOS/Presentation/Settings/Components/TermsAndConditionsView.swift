//
//  TermsAndConditionsView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI

struct TermsAndConditionsView: View {
    
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
                            termsSection(
                                title: "1. Aceptación de términos",
                                content: "Al usar Monederito, aceptás estos términos y condiciones. Si no estás de acuerdo, por favor no utilices la aplicación."
                            )
                            
                            termsSection(
                                title: "2. Descripción del servicio",
                                content: "Monederito es una plataforma de gestión financiera familiar que permite a tutores controlar y aprobar gastos de sus beneficiarios, con alertas de riesgo en tiempo real y educación financiera integrada."
                            )
                            
                            termsSection(
                                title: "3. Responsabilidades del usuario",
                                content: "Sos responsable de mantener segura tu cuenta y contraseña. Debes proporcionar información veraz y exacta al registrarte. Notificarnos inmediatamente cualquier uso no autorizado de tu cuenta."
                            )
                            
                            termsSection(
                                title: "4. Uso permitido",
                                content: "Podés usar Monederito exclusivamente para fines legítimos y de acuerdo con estos términos. Está prohibido usar la plataforma para actividades ilegales, fraude o lavado de dinero."
                            )
                            
                            termsSection(
                                title: "5. Límites de responsabilidad",
                                content: "Monederito no se hace responsable por pérdidas directas o indirectas derivadas del uso de la plataforma, incluyendo pero no limitado a pérdidas financieras, interrupciones del servicio o errores técnicos."
                            )
                            
                            termsSection(
                                title: "6. Propiedad intelectual",
                                content: "Todo el contenido de Monederito, incluyendo diseño, texto, gráficos y código, es propiedad exclusiva de Monederito y está protegido por leyes de propiedad intelectual."
                            )
                            
                            termsSection(
                                title: "7. Modificaciones del servicio",
                                content: "Nos reservamos el derecho de modificar, suspender o discontinuar cualquier aspecto del servicio en cualquier momento sin previo aviso."
                            )
                            
                            termsSection(
                                title: "8. Resolución de disputas",
                                content: "Cualquier disputa relacionada con el uso de Monederito se regirá por las leyes de la República Argentina y se resolverá en los tribunales competentes de la Ciudad Autónoma de Buenos Aires."
                            )
                            
                            termsSection(
                                title: "9. Contacto",
                                content: "Para cualquier pregunta sobre estos términos, podés contactarnos a través del centro de ayuda o por email a soporte@monederito.com"
                            )
                        }
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Términos y condiciones")
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
            
            Text("Términos de uso de Monederito")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Por favor leé estos términos cuidadosamente antes de usar Monederito.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
    
    @ViewBuilder
    private func termsSection(title: String, content: String) -> some View {
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
    TermsAndConditionsView()
}
