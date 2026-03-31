//
//  EditProfileView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Avatar grande editable
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.monederitoOrange, Color.monederitoPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text(viewModel.editedFullName.prefix(1).uppercased())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                    
                    // Campos
                    VStack(spacing: 16) {
                        AuthTextField(
                            title: "Nombre completo",
                            icon: "person.fill",
                            text: $viewModel.editedFullName,
                            isValid: viewModel.editedFullName.isEmpty ? nil
                                : !viewModel.editedFullName.trimmingCharacters(in: .whitespaces).isEmpty
                        )
                        
                        AuthTextField(
                            title: "Email",
                            icon: "envelope.fill",
                            text: $viewModel.editedEmail,
                            keyboardType: .emailAddress,
                            isValid: viewModel.editedEmail.isEmpty ? nil
                                : viewModel.editedEmail.contains("@")
                        )
                        
                        AuthTextField(
                            title: "Teléfono",
                            icon: "phone.fill",
                            text: $viewModel.editedPhone,
                            keyboardType: .phonePad
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Guardar
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView().tint(.white).scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Guardar cambios")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.monederitoOrange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .disabled(viewModel.isSaving)
                }
                .padding(.vertical, 16)
            }
            .background(Color.monederitoBackground.ignoresSafeArea())
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
}
