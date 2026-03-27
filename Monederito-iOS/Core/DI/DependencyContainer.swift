//
//  DependencyContainer.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

// CONCEPTO: Dependency Injection Container
// Este es el único lugar donde decidimos qué implementación usar.
// Para desarrollo: MockRepositories
// Para producción: SupabaseRepositories
//
// Los ViewModels NUNCA crean sus repositorios directamente.
// Los reciben desde afuera → más fácil de testear y cambiar.

@Observable
final class DependencyContainer {
    
    // MARK: - Repositories
    // Guardados como protocolos — no como implementaciones concretas
    let authRepository: any AuthRepositoryProtocol
    let transactionRepository: any TransactionRepositoryProtocol
    let userRepository: any UserRepositoryProtocol
    
    // MARK: - Singleton para desarrollo
    static let mock = DependencyContainer(environment: .mock)
    
    // CONCEPTO: enum para controlar el ambiente
    enum Environment {
        case mock       // desarrollo sin backend
        case supabase   // producción con Supabase
    }
    
    init(environment: Environment) {
        switch environment {
        case .mock:
            self.authRepository = MockAuthRepository()
            self.transactionRepository = MockTransactionRepository()
            self.userRepository = MockUserRepository()
            
        case .supabase:
            // En el Paso 13 reemplazamos por:
            // self.authRepository = SupabaseAuthRepository()
            // self.transactionRepository = SupabaseTransactionRepository()
            // self.userRepository = SupabaseUserRepository()
            // Por ahora fallback a mock
            self.authRepository = MockAuthRepository()
            self.transactionRepository = MockTransactionRepository()
            self.userRepository = MockUserRepository()
        }
    }
}
