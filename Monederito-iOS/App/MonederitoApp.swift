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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // CONCEPTO: .environment() — inyección de dependencias de SwiftUI.
                // Cualquier View descendiente puede hacer @Environment(AppState.self)
                // para acceder a este mismo objeto.
                .environment(appState)
        }
    }
}
