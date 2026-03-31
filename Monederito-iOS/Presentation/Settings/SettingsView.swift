//
//  SettingsView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    
    @State private var viewModel = SettingsViewModel()
    @State private var showEditProfile = false
    @State private var showDeleteConfirmation = false
    
    // CONCEPTO: @AppStorage — lee y escribe en UserDefaults automáticamente
    // Cuando cambia, la View se re-renderiza igual que @State
    @AppStorage(UserPreferences.Keys.notificationsEnabled)
    private var notificationsEnabled: Bool = UserPreferences.defaultNotifications
    
    @AppStorage(UserPreferences.Keys.biometricsEnabled)
    private var biometricsEnabled: Bool = UserPreferences.defaultBiometrics
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Header de perfil
                if let user = appState.currentUser {
                    ProfileHeaderView(user: user) {
                        showEditProfile = true
                    }
                    .padding(.horizontal)
                }
                
                // Sección: Cuenta
                SettingsSectionView(title: "Mi cuenta") {
                    SettingsRowView(
                        icon: "person.fill",
                        iconColor: Color.monederitoOrange,
                        title: "Editar perfil",
                        subtitle: "Nombre, email y teléfono"
                    ) {
                        showEditProfile = true
                    }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "creditcard.fill",
                        iconColor: Color.monederitoPurple,
                        title: "Mis datos bancarios",
                        subtitle: "CVU y alias de tu cuenta"
                    ) { }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "doc.text.fill",
                        iconColor: Color.safeGreen,
                        title: "Historial completo",
                        subtitle: "Todos tus movimientos"
                    ) { }
                }
                .padding(.horizontal)
                
                // Sección: Seguridad
                SettingsSectionView(title: "Seguridad") {
                    SettingsToggleRowView(
                        icon: viewModel.biometricType == "Face ID" ? "faceid" : "touchid",
                        iconColor: Color.monederitoOrange,
                        title: viewModel.biometricType,
                        subtitle: "Ingresá sin contraseña",
                        isOn: $biometricsEnabled
                    )
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "lock.fill",
                        iconColor: Color.monederitoPurple,
                        title: "Cambiar contraseña"
                    ) { }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "key.fill",
                        iconColor: Color.warningAmber,
                        title: "PIN de operaciones",
                        subtitle: "Para confirmar transferencias"
                    ) { }
                }
                .padding(.horizontal)
                
                // Sección: Notificaciones
                SettingsSectionView(title: "Notificaciones") {
                    SettingsToggleRowView(
                        icon: "bell.fill",
                        iconColor: Color.riskRed,
                        title: "Alertas de riesgo",
                        subtitle: "Gastos que requieren tu aprobación",
                        isOn: $notificationsEnabled
                    )
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "bell.badge.fill",
                        iconColor: Color.monederitoOrange,
                        title: "Preferencias de notificaciones",
                        subtitle: "Qué alertas querés recibir"
                    ) { }
                }
                .padding(.horizontal)
                
                // Sección: Información
                SettingsSectionView(title: "Información") {
                    SettingsRowView(
                        icon: "questionmark.circle.fill",
                        iconColor: Color.monederitoOrange,
                        title: "Centro de ayuda"
                    ) { }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "shield.fill",
                        iconColor: Color.monederitoPurple,
                        title: "Política de privacidad"
                    ) { }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "doc.fill",
                        iconColor: Color.safeGreen,
                        title: "Términos y condiciones"
                    ) { }
                    
                    Divider().padding(.leading, 66)
                    
                    // Versión de la app
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Image(systemName: "info.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Text("Versión")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                        Text("1.0.0 (build 1)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal)
                
                // Sección: Sesión
                SettingsSectionView(title: "Sesión") {
                    SettingsRowView(
                        icon: "rectangle.portrait.and.arrow.right",
                        iconColor: Color.riskRed,
                        title: "Cerrar sesión",
                        showChevron: false,
                        destructive: true
                    ) {
                        Task {
                            await viewModel.signOut(
                                using: container.authRepository,
                                appState: appState
                            )
                        }
                    }
                    
                    Divider().padding(.leading, 66)
                    
                    SettingsRowView(
                        icon: "trash.fill",
                        iconColor: Color.riskRed,
                        title: "Eliminar cuenta",
                        subtitle: "Esta acción es irreversible",
                        showChevron: false,
                        destructive: true
                    ) {
                        showDeleteConfirmation = true
                    }
                }
                .padding(.horizontal)
                
                // Footer
                Text("Monederito © 2025 — Hecho con ❤️ en Argentina")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let user = appState.currentUser {
                viewModel.loadProfile(from: user)
            }
        }
        // Toast de éxito
        .overlay(alignment: .top) {
            if let message = viewModel.successMessage {
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.safeGreen)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.4), value: viewModel.successMessage)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(viewModel: viewModel) {
                Task {
                    if let user = appState.currentUser {
                        if let updated = await viewModel.saveProfile(
                            for: user,
                            using: container.authRepository
                        ) {
                            appState.currentUser = updated
                        }
                    }
                }
            }
        }
        .confirmationDialog(
            "¿Eliminar cuenta?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar permanentemente", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                    appState.signOut()
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Perderás todos tus datos, historial y configuraciones. Esta acción no se puede deshacer.")
        }
    }
}
