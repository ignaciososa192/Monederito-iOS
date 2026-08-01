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
    let operationsRepository: any OperationsRepositoryProtocol
    let educationRepository: any EducationRepositoryProtocol
    
    // MARK: - Services
    let analyticsService: any AnalyticsServiceProtocol
    let analyticsManager: AnalyticsManager
    
    // MARK: - Singleton para desarrollo
    // Automatically selects environment based on build configuration
    static let current = DependencyContainer.currentEnvironment
    
    // CONCEPTO: enum para controlar el ambiente
    enum Environment {
        case mock       // desarrollo sin backend
        case supabase   // producción con Supabase
    }
    
    // Detect current environment from build configuration
    private static var currentEnvironment: DependencyContainer {
        #if DEBUG
        return DependencyContainer(environment: .mock)
        #else
        return DependencyContainer(environment: .supabase)
        #endif
    }
    
    init(environment: Environment) {
        switch environment {
        case .mock:
            let analytics = MockAnalyticsService()
            self.authRepository = MockAuthRepository()
            self.transactionRepository = MockTransactionRepository()
            self.userRepository = MockUserRepository()
            self.operationsRepository = MockOperationsRepository()
            self.educationRepository = MockEducationRepository()
            self.analyticsService = analytics
            self.analyticsManager = AnalyticsManager(analyticsService: analytics)
            
        case .supabase:

            let transactionRepo = SupabaseTransactionRepository()
            let analytics = FirebaseAnalyticsService()
            self.authRepository = SupabaseAuthRepository()
            self.transactionRepository = transactionRepo
            self.userRepository = SupabaseUserRepository()
            self.operationsRepository = SupabaseOperationsRepository(transactionRepository: transactionRepo)
            self.educationRepository = SupabaseEducationRepository()
            self.analyticsService = analytics
            self.analyticsManager = AnalyticsManager(analyticsService: analytics)
        }
    }
}
