//
//  SettingsViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI
import LocalAuthentication

@Observable
class SettingsViewModel {
    
    // MARK: - Profile State
    var editedFullName: String = ""
    var editedPhone: String = ""
    var editedEmail: String = ""
    var isEditingProfile: Bool = false
    var isSaving: Bool = false
    var successMessage: String? = nil
    
    // MARK: - Preferences
    // CONCEPTO: @AppStorage dentro de un @Observable
    // Usamos UserDefaults directamente para sincronizar
    // con @AppStorage en las Views
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: UserPreferences.Keys.notificationsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: UserPreferences.Keys.notificationsEnabled) }
    }
    
    var biometricsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: UserPreferences.Keys.biometricsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: UserPreferences.Keys.biometricsEnabled) }
    }
    
    // MARK: - Biometric info
    var biometricType: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "No disponible"
        }
        switch context.biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default:       return "Biometría"
        }
    }
    
    // MARK: - Init con datos del usuario
    func loadProfile(from user: User) {
        editedFullName = user.fullName
        editedEmail    = user.email
        editedPhone    = ""
        
        // Inicializar UserDefaults con defaults si es primera vez
        if UserDefaults.standard.object(forKey: UserPreferences.Keys.notificationsEnabled) == nil {
            UserDefaults.standard.set(UserPreferences.defaultNotifications,
                                      forKey: UserPreferences.Keys.notificationsEnabled)
        }
    }
    
    // MARK: - Actions
    func saveProfile(for user: User, using repo: any AuthRepositoryProtocol) async -> User? {
        isSaving = true
        
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
            var updated = user
            updated.fullName = editedFullName
            // En Paso 13: return try await repo.updateProfile(updated)
            successMessage = "Perfil actualizado ✅"
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            successMessage = nil
            isSaving = false
            return updated
        } catch {
            isSaving = false
            return nil
        }
    }
    
    func signOut(using repo: any AuthRepositoryProtocol, appState: AppState) async {
        do {
            try await repo.signOut()
        } catch { }
        appState.signOut()
    }
    
    func deleteAccount() async {
        // Paso 13: implementar eliminación real
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
