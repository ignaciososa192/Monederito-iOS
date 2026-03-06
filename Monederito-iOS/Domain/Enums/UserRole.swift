//
//  UserRole.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

// CONCEPTO: enum en Swift es mucho más poderoso que en otros lenguajes.
// Puede tener métodos, propiedades y casos asociados (associated values).

enum UserRole: String, Codable, CaseIterable {
    case benefactor  // Elena/Pedro: controla y aprueba
    case beneficiary // Hijo adolescente o adulto mayor
    
    var displayName: String {
        switch self {
        case .benefactor:  return "Tutor / Responsable"
        case .beneficiary: return "Beneficiario"
        }
    }
    
    var isBenefactor: Bool {
        self == .benefactor
    }
}
