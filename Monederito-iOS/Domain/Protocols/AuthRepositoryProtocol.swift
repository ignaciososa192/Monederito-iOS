//
//  AuthRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// CONCEPTO CLAVE: Protocol como interfaz (del comentario del entrevistador)
// Un protocol define QUÉ se puede hacer, sin decir CÓMO.
// Esto permite tener una implementación real (Supabase) y una de prueba (mock)
// sin cambiar ni una línea de los ViewModels.

// CONCEPTO: async throws — función asíncrona que puede fallar
// - async: no bloquea el hilo principal mientras espera la red
// - throws: puede lanzar un error que debés capturar con try/catch

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, fullName: String, role: UserRole) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
}
