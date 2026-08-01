//
//  SecurityServiceProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/07/2026.
//

import Foundation

protocol SecurityServiceProtocol {
    func authenticate() async throws -> Bool
    func isBiometricAvailable() -> Bool
    func saveCredential(_ credential: String, forKey key: String) throws
    func getCredential(forKey key: String) throws -> String?
    func deleteCredential(forKey key: String) throws
}