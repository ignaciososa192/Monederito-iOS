//
//  HelpCenterView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI

struct HelpCenterView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let helpTopics = [
        HelpTopic(
            icon: "shield.fill",
            title: "Cómo funciona Monederito",
            description: "Entendé el flujo de aprobaciones y alertas de riesgo"
        ),
        HelpTopic(
            icon: "bell.fill",
            title: "Configurar notificaciones",
            description: "Aprendé a personalizar tus alertas de riesgo"
        ),
        HelpTopic(
            icon: "creditcard.fill",
            title: "Agregar métodos de pago",
            description: "Conectá tu cuenta bancaria o tarjeta"
        ),
        HelpTopic(
            icon: "person.2.fill",
            title: "Agregar beneficiarios",
            description: "Cómo invitar a tus hijos o tutelados"
        ),
        HelpTopic(
            icon: "chart.pie.fill",
            title: "Límites y presupuestos",
            description: "Configurá controles de gasto por usuario"
        ),
        HelpTopic(
            icon: "exclamationmark.triangle.fill",
            title: "Reportar un problema",
            description: "Contactanos si encontrás un error"
        )
    ]
    
    var filteredTopics: [HelpTopic] {
        if searchText.isEmpty {
            return helpTopics
        }
        return helpTopics.filter { topic in
            topic.title.localizedCaseInsensitiveContains(searchText) ||
            topic.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchSection
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredTopics, id: \.title) { topic in
                                helpTopicCard(topic)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Centro de ayuda")
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
    private var searchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            TextField("Buscar ayuda...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func helpTopicCard(_ topic: HelpTopic) -> some View {
        Button {
            // In a real app, this would navigate to detailed help content
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.monederitoOrange.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: topic.icon)
                        .font(.title3)
                        .foregroundColor(Color.monederitoOrange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(topic.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HelpTopic {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    HelpCenterView()
}
