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
    
    // ⚠️ IMPORTANTE: Nunca commitees estas claves a Git
    // En producción usar variables de entorno o un archivo .xcconfig excluido del repo
    static let projectURL = "https://ozwksugidtuhlacsearf.supabase.co"
    static let anonKey    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96d2tzdWdpZHR1aGxhY3NlYXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NzQ2NDgsImV4cCI6MjA5MjE1MDY0OH0.kZ4onAAjbY2Pj-sLMMUWNOF0yX-oo2V3YlUQWGYl1Z4"
    
    static var isValid: Bool {
        // For development, we'll consider it valid if both are set
        // In production, you should validate these against environment variables
        !projectURL.isEmpty && !anonKey.isEmpty && 
        projectURL.hasPrefix("https://") && 
        anonKey.count > 50 // JWT tokens are typically longer than 50 chars
    }
    
    // MARK: - Google Sign-In Configuration
    // Replace the placeholder with your real client ID, or set the "GOOGLE_CLIENT_ID"
    // key in your Info.plist and we'll read it from there.
    static let googleClientID: String = "525232504558-hpo1s9qsq7pvrat5p2j01u81b8ut0b08.apps.googleusercontent.com"
    
    static var isGoogleConfigured: Bool {
        // Consider it configured when it doesn't contain the placeholder
        // and looks like a valid Google client ID.
        return !googleClientID.isEmpty && 
               googleClientID.hasSuffix(".apps.googleusercontent.com") &&
               googleClientID.contains(".apps.googleusercontent.com")
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

