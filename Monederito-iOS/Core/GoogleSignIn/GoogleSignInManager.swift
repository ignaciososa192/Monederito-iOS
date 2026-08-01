//
//  GoogleSignInManager.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import Foundation
import GoogleSignIn
import UIKit

// Resultado del login con Google
struct GoogleSignInResult {
    let fullName: String
    let email: String
    let idToken: String      // lo necesita Supabase
    let accessToken: String
}

@MainActor
final class GoogleSignInManager {
    
    static let shared = GoogleSignInManager()
    private init() { }
    
    func signInWithGoogle() async throws -> GoogleSignInResult {
        
        // Obtener el rootViewController activo
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AppError.googleSignInFailed
        }
        
        // CONCEPTO: withCheckedThrowingContinuation
        // Convierte el callback de GIDSignIn a async/await
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if error != nil {
                    continuation.resume(throwing: AppError.googleSignInFailed)
                    return
                }
                
                guard let result,
                      let idToken = result.user.idToken?.tokenString else {
                    continuation.resume(throwing: AppError.missingGoogleToken)
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                let fullName = result.user.profile?.name ?? "Usuario"
                let email = result.user.profile?.email ?? ""
                
                continuation.resume(returning: GoogleSignInResult(
                    fullName: fullName,
                    email: email,
                    idToken: idToken,
                    accessToken: accessToken
                ))
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // Restaurar sesión de Google si existe
    func restorePreviousSignIn() async -> GoogleSignInResult? {
        return try? await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                guard let user, error == nil,
                      let idToken = user.idToken?.tokenString else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: GoogleSignInResult(
                    fullName: user.profile?.name ?? "",
                    email: user.profile?.email ?? "",
                    idToken: idToken,
                    accessToken: user.accessToken.tokenString
                ))
            }
        }
    }
}
