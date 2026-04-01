//
//  MonederitoApp.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import SwiftUI

@main
struct MonederitoApp: App {
    
    // CONCEPTO: @State en el App struct
    // AppState vive aquí — es el nivel más alto de la app.
    // Al inyectarlo con .environment(), todas las Views hijas pueden accederlo.
    @State private var appState = AppState()
    @State private var notificationManager = NotificationManager.shared
    
    // El container decide qué repositorios utilizar
    // Cambiá .mock por .supabase cuando conectemos el backend
    private let container = DependencyContainer.mock
    private let notificationDelegate = NotificationDelegate()

    init() {
        //Config del delegate antes de iniciar la app
        notificationDelegate.transactionRepository = container.transactionRepository
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationManager.shared.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // CONCEPTO: .environment() — inyección de dependencias de SwiftUI.
                // Cualquier View descendiente puede hacer @Environment(AppState.self)
                // para acceder a este mismo objeto.
                .environment(appState)
                .environment(container)
                .environment(notificationManager)
            // CONCEPTO: onAppear para pedir permisos al iniciar
                .task {
                    notificationDelegate.appState = appState
                    if !notificationManager.isAuthorized {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.clearBadge()
                }
                .onChange(of: notificationManager.pendingDeepLink) { _, deepLink in
                    handleDeepLink(deepLink)
                }
        }
    }

    private func handleDeepLink(_ deepLink: DeepLink?) {
        guard let deepLink else { return }

        switch deepLink {
        case .riskAlert(let alertID):
            appState.selectedTab = BenefactorTab.alerts
            appState.pendingAlertID = alertID
            notificationManager.pendingDeepLink = nil
        
        case .transaction:
            appState.selectedTab = BenefactorTab.dashboard
            notificationManager.pendingDeepLink = nil
        
        default:
            notificationManager.pendingDeepLink = nil
        }
    }
}
