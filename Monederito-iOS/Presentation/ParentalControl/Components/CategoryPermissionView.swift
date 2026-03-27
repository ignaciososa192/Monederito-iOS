//
//  CategoryPermissionView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct CategoryPermissionView: View {
    
    @Binding var account: BeneficiaryAccount
    let onToggle: (TransactionCategory, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    
                    // Info
                    HStack(spacing: 12) {
                        Image(systemName: "shield.fill")
                            .foregroundColor(Color.monederitoPurple)
                        Text("Las categorías bloqueadas dispararán una alerta para tu aprobación antes de que Lucas pueda gastar.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(14)
                    .background(Color.monederitoPurple.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Categorías de riesgo primero
                    categoryGroup(
                        title: "⚠️ Categorías de Riesgo",
                        categories: TransactionCategory.allCases.filter { $0.isRisky }
                    )
                    
                    // Categorías normales
                    categoryGroup(
                        title: "✅ Categorías Permitidas",
                        categories: TransactionCategory.allCases.filter { !$0.isRisky }
                    )
                }
                .padding(.vertical)
            }
            .background(Color.monederitoBackground.ignoresSafeArea())
            .navigationTitle("Permisos de Categorías")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private func categoryGroup(title: String, categories: [TransactionCategory]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(categories, id: \.self) { category in
                    let isBlocked = account.blockedCategories.contains(category)
                    
                    HStack(spacing: 14) {
                        // Emoji + nombre
                        Text(category.emoji)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text(isBlocked ? "Requiere aprobación" : "Permitido libremente")
                                .font(.caption)
                                .foregroundColor(isBlocked ? Color.riskRed : Color.safeGreen)
                        }
                        
                        Spacer()
                        
                        // CONCEPTO: Toggle con Binding
                        // El Toggle necesita un Binding<Bool>.
                        // Creamos uno custom con get/set.
                        Toggle("", isOn: Binding(
                            get: { isBlocked },
                            set: { newValue in
                                onToggle(category, newValue)
                            }
                        ))
                        .tint(Color.riskRed)
                        .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if category != categories.last {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .padding(.horizontal)
        }
    }
}
