//
//  ProfileHeaderView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    let user: User
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.monederitoOrange, Color.monederitoPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(user.fullName.prefix(1).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Botón editar sobre el avatar
                Button(action: onEdit) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)
                        Image(systemName: "pencil")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.monederitoOrange)
                    }
                }
                .offset(x: 28, y: 28)
            }
            .padding(.bottom, 8)
            
            // Info
            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Badge de rol
                HStack(spacing: 6) {
                    Image(systemName: user.isBenefactor ? "shield.fill" : "person.fill")
                        .font(.caption)
                    Text(user.role.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(user.isBenefactor ? Color.monederitoOrange : Color.monederitoPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    (user.isBenefactor ? Color.monederitoOrange : Color.monederitoPurple)
                        .opacity(0.1)
                )
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
