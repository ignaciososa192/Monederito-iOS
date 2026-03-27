//
//  AuthViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI
import LocalAuthentication

@Observable
class AuthViewModel {
    
    // MARK: - Form State
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var fullName: String = ""
    var phone: String = ""
    var selectedRole: UserRole = .benefactor
    
    // MARK: - UI State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showPassword: Bool = false
    var showConfirmPassword: Bool = false
    
    // MARK: - Biometrics
    var biometricType: BiometricType = .none
    
    enum BiometricType {
        case faceID, touchID, none
        
        var icon: String {
            switch self {
            case .faceID:  return "faceid"
            case .touchID: return "touchid"
            case .none:    return ""
            }
        }
        
        var label: String {
            switch self {
            case .faceID:  return "Face ID"
            case .touchID: return "Touch ID"
            case .none:    return ""
            }
        }
    }
    
    // MARK: - Validaciones en tiempo real
    // CONCEPTO: computed properties reactivas
    // Cada vez que email/password cambian, estas propiedades
    // se recalculan automáticamente y la View se actualiza.
    
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var isPasswordValid: Bool {
        password.count >= 8
    }
    
    var doPasswordsMatch: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }
    
    var isPhoneValid: Bool {
        let cleaned = phone.filter { $0.isNumber }
        return cleaned.count >= 10
    }
    
    var isLoginFormValid: Bool {
        isEmailValid && isPasswordValid
    }
    
    var isRegisterFormValid: Bool {
        isEmailValid &&
        isPasswordValid &&
        doPasswordsMatch &&
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isPhoneValid
    }
    
    // MARK: - Auth Actions
    
    func signIn(using repository: any AuthRepositoryProtocol, appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await repository.signIn(email: email, password: password)
            appState.currentUser = user
            appState.isAuthenticated = true
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ocurrió un error inesperado"
        }
        
        isLoading = false
    }
    
    func signUp(using repository: any AuthRepositoryProtocol, appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await repository.signUp(
                email: email,
                password: password,
                fullName: fullName,
                role: selectedRole,
                phone: phone
            )
            appState.currentUser = user
            appState.isAuthenticated = true
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ocurrió un error inesperado"
        }
        
        isLoading = false
    }
    
    // MARK: - Biometría
    // CONCEPTO: LocalAuthentication framework
    // Permite usar Face ID / Touch ID sin manejar credenciales.
    // El sistema operativo maneja la seguridad — nosotros solo
    // pedimos evaluación y reaccionamos al resultado.
    
    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:  biometricType = .faceID
            case .touchID: biometricType = .touchID
            default:       biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }
    
    func authenticateWithBiometrics(using repository: any AuthRepositoryProtocol, appState: AppState) async {
        let context = LAContext()
        let reason = "Ingresá a Monederito con \(biometricType.label)"
        
        do {
            // CONCEPTO: withCheckedThrowingContinuation
            // Convierte una API de callbacks (antigua) a async/await (moderna).
            // LAContext usa completion handlers — esto lo "moderniza".
            let success: Bool = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                ) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
            
            if success {
                // En producción: recuperar credenciales del Keychain
                // Por ahora simulamos login exitoso
                appState.loginAsBenefactor()
            }
        } catch {
            // El usuario canceló o falló — no mostramos error
            // (es comportamiento esperado)
        }
    }
    
    // MARK: - Helpers
    func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
        phone = ""
        errorMessage = nil
    }
}

