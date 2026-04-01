//
//  AppState.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

@Observable
class AppState {
    
    // MARK: - Session State
    var currentUser: User? = nil
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var error: AppError? = nil
    var selectedTab: BenefactorTab = .dashboard
    var pendingAlertID: UUID? = nil
    
    // MARK: - Computed
    var userRole: UserRole? { currentUser?.role }
    var isBenefactor: Bool { userRole == .benefactor }
    
    // MARK: - Auth con repositorio real
    // CONCEPTO: el AppState ahora recibe el repositorio
    // en lugar de usar MockData directamente
    
    func signIn(email: String, password: String, using repository: any AuthRepositoryProtocol) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await repository.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.serverError(code: 0, message: error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func signOut(using repository: any AuthRepositoryProtocol) async {
        do {
            try await repository.signOut()
        } catch { }
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Quick login para desarrollo (lo eliminamos en Paso 7)
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
