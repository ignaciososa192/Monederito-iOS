//
//  User.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import Foundation

// CONCEPTO: struct vs class
// - struct: tipo por VALOR. Cuando lo copiás, obtenés una copia independiente.
// - class: tipo por REFERENCIA. Cuando lo copiás, ambas variables apuntan al mismo objeto.
// En Swift, se prefieren structs para modelos de datos (son más seguros con concurrencia).

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var fullName: String
    var email: String
    var role: UserRole
    var avatarURL: String?
    
    // Relaciones: un benefactor puede tener varios beneficiarios
    // CONCEPTO: Optional (?) — puede tener valor o ser nil. Siempre debés "desenvolverlo" antes de usar.
    var beneficiaryIDs: [UUID]?
    var benefactorID: UUID?
    
    // Límites configurados por el benefactor
    var monthlyLimit: Double?
    var dailyLimit: Double?
    
    var isBenefactor: Bool { role == .benefactor }
    
    // CONCEPTO: Memberwise initializer con valores por defecto
    init(
        id: UUID = UUID(),
        fullName: String,
        email: String,
        role: UserRole,
        avatarURL: String? = nil,
        beneficiaryIDs: [UUID]? = nil,
        benefactorID: UUID? = nil,
        monthlyLimit: Double? = nil,
        dailyLimit: Double? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.role = role
        self.avatarURL = avatarURL
        self.beneficiaryIDs = beneficiaryIDs
        self.benefactorID = benefactorID
        self.monthlyLimit = monthlyLimit
        self.dailyLimit = dailyLimit
    }
}
