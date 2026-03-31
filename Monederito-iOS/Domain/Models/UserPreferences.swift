//
//  UserPreferences.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

// CONCEPTO: @AppStorage — persiste valores simples en UserDefaults
// automáticamente. Es la forma SwiftUI de guardar preferencias
// del usuario entre sesiones sin código adicional.

struct UserPreferences {
    
    // Claves para UserDefaults — centralizadas para evitar typos
    enum Keys {
        static let notificationsEnabled = "notificationsEnabled"
        static let biometricsEnabled    = "biometricsEnabled"
        static let darkModeEnabled      = "darkModeEnabled"
        static let language             = "language"
        static let currency             = "currency"
        static let hasSeenOnboarding    = "hasSeenOnboarding"
    }
    
    // Valores por defecto
    static let defaultNotifications = true
    static let defaultBiometrics    = false
    static let defaultDarkMode      = false
    static let defaultLanguage      = "es"
    static let defaultCurrency      = "ARS"
}
