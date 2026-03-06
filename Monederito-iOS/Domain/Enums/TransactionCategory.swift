//
//  TransactionCategory.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

// CONCEPTO: Associated values — cada caso puede llevar datos distintos.
// Esto es único de Swift y muy poderoso para modelar el dominio.

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    
    // Categorías seguras
    case food           = "Comida"
    case transport      = "Transporte"
    case education      = "Educación"
    case health         = "Salud"
    case entertainment  = "Entretenimiento"
    case services       = "Servicios"
    case savings        = "Ahorro"
    
    // Categorías de riesgo — estas disparan alertas
    case gambling       = "Apuestas"
    case highRiskInvest = "Inversión de alto riesgo"
    case unknown        = "Desconocido"
    
    var id: String { rawValue }
    
    // CONCEPTO: propiedad computada — se calcula cada vez que se accede
    var isRisky: Bool {
        switch self {
        case .gambling, .highRiskInvest, .unknown:
            return true
        default:
            return false
        }
    }
    
    var emoji: String {
        switch self {
        case .food:           return "🍔"
        case .transport:      return "🚌"
        case .education:      return "📚"
        case .health:         return "💊"
        case .entertainment:  return "🎬"
        case .services:       return "💡"
        case .savings:        return "🐷"
        case .gambling:       return "🎰"
        case .highRiskInvest: return "⚠️"
        case .unknown:        return "❓"
        }
    }
    
    var colorName: String {
        isRisky ? "riskRed" : "safeGreen"
    }
}
