//
//  AppState.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

@MainActor
@Observable
class AppState {
    
    // MARK: - Session State
    var isRestoringSession = true
    var requiresPasswordUpdate = false
    private var sessionRevision = 0
    var currentUser: User? = nil
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var error: AppError? = nil
    var selectedBenefactorTab: BenefactorTab = .dashboard
    var selectedBeneficiaryTab: BeneficiaryTab = .wallet
    var pendingAlertID: UUID? = nil
    var pendingOperation: OperationsMainView.OperationType? = nil
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }
    
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
    
    func restoreSession(using repository: any AuthRepositoryProtocol) async {
        let revision = sessionRevision
        defer { isRestoringSession = false }
        do {
            let user = try await repository.getCurrentUser()
            guard revision == sessionRevision else { return }
            currentUser = user
            isAuthenticated = user != nil && !requiresPasswordUpdate
            error = nil
        } catch {
            guard revision == sessionRevision else { return }
            self.error = (error as? AppError) ?? .serverError(code: 0, message: error.localizedDescription)
        }
    }

    func signOut(using repository: any AuthRepositoryProtocol) async {
        signOut()
        do {
            try await repository.signOut()
        } catch {
            self.error = (error as? AppError) ?? .serverError(code: 0, message: error.localizedDescription)
        }
    }

    func observeSession(using repository: any AuthRepositoryProtocol) async {
        for await event in repository.sessionEvents() {
            switch event {
            case .signedOut: signOut()
            case .passwordRecovery:
                requiresPasswordUpdate = true
                isAuthenticated = false
            }
        }
    }

    func handleAuthCallback(_ url: URL, using repository: any AuthRepositoryProtocol) async {
        isRestoringSession = true
        do {
            try await repository.handleAuthCallback(url)
            if url.path == "/recovery" { requiresPasswordUpdate = true }
            await restoreSession(using: repository)
        } catch {
            isRestoringSession = false
            self.error = (error as? AppError) ?? .serverError(code: 0, message: "El enlace expiró o no es válido. Solicitá uno nuevo.")
        }
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
        sessionRevision += 1
        requiresPasswordUpdate = false
        selectedBenefactorTab = .dashboard
        selectedBeneficiaryTab = .wallet
        pendingAlertID = nil
        pendingOperation = nil
        currentUser = nil
        isAuthenticated = false
    }
}
