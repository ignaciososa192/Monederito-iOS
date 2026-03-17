//
//  AppState.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

// CONCEPTO: @Observable — macro de Swift 5.9+
// Convierte automáticamente las propiedades en observables.
// Las Views que lean estas propiedades se re-renderizan cuando cambian.

@Observable
class AppState {
    
    // MARK: - Session State
    var currentUser: User? = nil
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    
    // CONCEPTO: propiedad computada que deriva del estado existente
    // No almacena nada nuevo, solo interpreta lo que ya hay.
    var userRole: UserRole? {
        currentUser?.role
    }
    
    var isBenefactor: Bool {
        userRole == .benefactor
    }
    
    // MARK: - Mock login para desarrollo
    // Esto lo reemplazaremos en el Paso 3 con auth real de Supabase
    
    func loginAsBenefactor() {
        currentUser = MockData.benefactorUser
        isAuthenticated = true
    }
    
    func loginAsBeneficiary() {
        currentUser = MockData.beneficiaryUser
        isAuthenticated = true
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}
