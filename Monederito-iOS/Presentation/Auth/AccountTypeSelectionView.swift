//
//  AccountTypeSelectionView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI

struct AccountTypeSelectionView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRole: UserRole?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // Header
                        headerSection
                        
                        // Account type cards
                        VStack(spacing: 20) {
                            accountTypeCard(
                                role: .benefactor,
                                icon: "shield.fill",
                                title: "Tutor / Padre",
                                description: "Controlás los gastos de tu familia, configurás límites y aprobás transiciones en tiempo real.",
                                features: [
                                    "Dashboard completo de gastos familiares",
                                    "Alertas de riesgo en tiempo real",
                                    "Aprobación de transacciones",
                                    "Educación financiera para tus hijos"
                                ],
                                color: Color.monederitoOrange
                            )
                            
                            accountTypeCard(
                                role: .beneficiary,
                                icon: "person.fill",
                                title: "Beneficiario / Hijo",
                                description: "Recibís dinero, hacés compras y aprendés sobre finanzas de forma divertida.",
                                features: [
                                    "Billetera virtual personal",
                                    "Historial de tus gastos",
                                    "Misiones y recompensas",
                                    "Tips educativos en cada transacción"
                                ],
                                color: Color.monederitoPurple
                            )
                        }
                        
                        // Continue button
                        if selectedRole != nil {
                            continueButton
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("¿Cómo querés usar Monederito?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.monederitoOrange)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Elegí tu tipo de cuenta")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("Monederito se adapta a vos. Seleccioná el rol que mejor describa cómo querés usar la app.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func accountTypeCard(
        role: UserRole,
        icon: String,
        title: String,
        description: String,
        features: [String],
        color: Color
    ) -> some View {
        let isSelected = selectedRole == role
        
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedRole = role
            }
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Icon and title
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 56, height: 56)
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(color)
                    }
                }
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(color)
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.08) : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: isSelected ? color.opacity(0.15) : .black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0, y: 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var continueButton: some View {
        Button {
            // Navigate to registration with selected role pre-selected
            // This will be handled by the parent view or navigation logic
            dismiss()
        } label: {
            HStack {
                Text("Continuar con \(selectedRole == .benefactor ? "Tutor" : "Beneficiario")")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.monederitoOrange)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }
}

#Preview {
    AccountTypeSelectionView(selectedRole: .constant(nil))
}
