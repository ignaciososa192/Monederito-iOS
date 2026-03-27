//
//  AppError.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

// CONCEPTO: enum para modelar errores — patrón muy común en Swift
// En lugar de usar Error genérico, definimos TODOS los errores posibles.
// Esto obliga al compilador a avisarnos si nos olvidamos de manejar un caso.

enum AppError: Error, LocalizedError {
    
    // Errores de autenticación
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case sessionExpired
    case unauthorized
    
    // Errores de red
    case networkUnavailable
    case timeout
    case serverError(code: Int, message: String)
    
    // Errores de datos
    case decodingFailed
    case notFound(resource: String)
    case insufficientFunds
    case limitExceeded(limit: Double)
    
    // Errores de operaciones
    case transactionBlocked(reason: String)
    case operationNotAllowed
    
    // CONCEPTO: propiedad del protocolo LocalizedError
    // Nos permite mostrar mensajes legibles al usuario
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .userNotFound:
            return "Usuario no encontrado"
        case .emailAlreadyInUse:
            return "Este email ya está registrado"
        case .sessionExpired:
            return "Tu sesión expiró. Iniciá sesión nuevamente"
        case .unauthorized:
            return "No tenés permisos para realizar esta acción"
        case .networkUnavailable:
            return "Sin conexión a internet. Verificá tu red"
        case .timeout:
            return "La operación tardó demasiado. Intentá de nuevo"
        case .serverError(_, let message):
            return "Error del servidor: \(message)"
        case .decodingFailed:
            return "Error al procesar los datos"
        case .notFound(let resource):
            return "\(resource) no encontrado"
        case .insufficientFunds:
            return "Saldo insuficiente para realizar esta operación"
        case .limitExceeded(let limit):
            let formatted = NumberFormatter.argentinePesos.string(from: NSNumber(value: limit)) ?? "$\(limit)"
            return "Límite de \(formatted) excedido"
        case .transactionBlocked(let reason):
            return "Operación bloqueada: \(reason)"
        case .operationNotAllowed:
            return "Esta operación no está permitida"
        }
    }
    
    // Si el error es recuperable (el usuario puede reintentar)
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .serverError:
            return true
        default:
            return false
        }
    }
}

// CONCEPTO: Extension en el mismo archivo para mantener todo junto
extension NumberFormatter {
    static let argentinePesos: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "es_AR")
        return f
    }()
}
