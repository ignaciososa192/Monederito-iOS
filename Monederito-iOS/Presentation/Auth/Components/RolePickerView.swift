//
//  RolePickerView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct RolePickerView: View {
    
    @Binding var selectedRole: UserRole
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Cuál es tu rol?")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    roleCard(role)
                }
            }
        }
    }
    
    @ViewBuilder
    private func roleCard(_ role: UserRole) -> some View {
        
        let isSelected = selectedRole == role
        
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedRole = role
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: role == .benefactor ? "shield.fill" : "person.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color.monederitoOrange)
                
                Text(role == .benefactor ? "Tutor" : "Beneficiario")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .black)
                
                Text(role == .benefactor ? "Controlás gastos" : "Recibís dinero")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? LinearGradient(colors: [Color.monederitoOrange, Color.monederitoPurple],
                                          startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.white, Color.white],
                                          startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .shadow(
                color: isSelected ? Color.monederitoOrange.opacity(0.3) : .black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0, y: 3
            )
        }
    }
}
