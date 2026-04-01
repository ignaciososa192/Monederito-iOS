//
//  BenefactorTabView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

enum BenefactorTab: String {
    case dashboard, alerts, beneficiaries, settings
}

struct BenefactorTabView: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        TabView(selection: Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )) {
            
            // CONCEPTO: NavigationStack moderno (iOS 16+)
            // Reemplaza al viejo NavigationView.
            // El parámetro 'path' permite navegación programática.
            
            // Tab 1 — Dashboard
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(BenefactorTab.dashboard)
            
            // Tab 2 — Alertas (funcionalidad principal del PDF)
            NavigationStack {
                AlertsView()
            }
            .tabItem {
                Label("Alertas", systemImage: "bell.badge.fill")
            }
            .badge(/* pendingCount */ 0) // En Paso 12 conectamos el badge real
            .tag(BenefactorTab.alerts)
            
            // Tab 3 — Beneficiarios
            NavigationStack {
                ParentalControlView()
            }
            .tabItem {
                Label("Familia", systemImage: "person.2.fill")
            }
            .tag(BenefactorTab.beneficiaries)
            
            // Tab 4 — Configuración
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Config", systemImage: "gearshape.fill")
            }
            .tag(BenefactorTab.settings)
        }
        .tint(Color.monederitoOrange)
    }
}
