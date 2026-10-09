//
//  SupabaseConfig.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import Foundation
import Supabase

// CONCEPTO: Singleton del cliente Supabase
// Un único cliente compartido en toda la app — patrón estándar del SDK

enum SupabaseConfig {
    
    // Publishable client configuration is supplied by the Sandbox xcconfig.
    static let projectURL = AppConfiguration.current?.supabaseURL ?? ""
    static let anonKey = AppConfiguration.current?.supabaseKey ?? ""
    static let googleClientID = AppConfiguration.current?.googleClientID ?? ""

    static var isValid: Bool {
        AppConfiguration.current?.environment == .sandbox && !projectURL.isEmpty && !anonKey.isEmpty
    }

    static var isGoogleConfigured: Bool {
        AppConfiguration.current?.environment == .sandbox && googleClientID.hasSuffix(".apps.googleusercontent.com")
    }

    // Cliente compartido — se inicializa una sola vez
    // Returns nil if configuration is invalid instead of crashing
    static var client: SupabaseClient? = {
        guard SupabaseConfig.isValid else {
            print("⚠️ Supabase configuration is invalid. Check projectURL and anonKey.")
            return nil
        }
        
        guard let url = URL(string: SupabaseConfig.projectURL) else {
            print("⚠️ Invalid Supabase URL: \(SupabaseConfig.projectURL)")
            return nil
        }
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.anonKey,
            options: .init(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }()
    
    // Nombres de tablas — centralizados para evitar typos
    enum Tables {
        static let profiles             = "profiles"
        static let beneficiaryAccounts  = "beneficiary_accounts"
        static let transactions         = "transactions"
        static let riskAlerts           = "risk_alerts"
        static let savingsGoals         = "savings_goals"
        static let transferDestinations = "transfer_destinations"
        static let userProgress         = "user_progress"
        static let lessons              = "lessons"
    }
}

