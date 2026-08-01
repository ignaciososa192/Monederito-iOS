//
//  RootView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

// CONCEPTO: RootView es el "árbitro" de navegación.
// Decide qué mostrar según el estado de la sesión.
// Es un patrón muy común en apps de producción.

struct RootView: View {
    
    @Environment(AppState.self) private var appState
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showAccountSelection = false
    @State private var selectedRole: UserRole?
    
    var body: some View {
        
        // CONCEPTO: Group + if/else en SwiftUI
        // SwiftUI es declarativo: describís QUÉ mostrar según el estado,
        // no CÓMO transicionar. El framework maneja las animaciones.
        
        Group {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .onChange(of: showOnboarding) { _, newValue in
                        if !newValue {
                            appState.hasCompletedOnboarding = true
                            // After onboarding, show account selection for new users
                            showAccountSelection = true
                        }
                    }
            } else if showAccountSelection {
                AccountTypeSelectionView(selectedRole: $selectedRole)
                    .onChange(of: selectedRole) { _, newValue in
                        if newValue != nil {
                            showAccountSelection = false
                        }
                    }
            } else if appState.isAuthenticated {
                // Usuario logueado — elegir TabView según rol
                if appState.isBenefactor {
                    BenefactorTabView()
                } else {
                    BeneficiaryTabView()
                }
            } else {
                LoginView()
            }
        }
        // Animación suave al cambiar entre estados
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}
