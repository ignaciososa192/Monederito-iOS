//
//  Operations.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import Foundation

// Modelos para las operaciones financieras del Paso 8

// MARK: - QR

struct QRMerchantData: Codable {
    let merchantID: String
    let merchantName: String
    let category: TransactionCategory
    let defaultAmount: Double?
}

// MARK: - Transferencia

struct TransferDestination: Identifiable, Codable {
    let id: UUID
    var recipientName: String
    var cbuOrCvu: String      // 22 dígitos
    var alias: String?
    var isMonederitoUser: Bool // si es usuario interno → 0% comisión
    
    // Validación de CBU/CVU
    var isValidCBUCVU: Bool {
        let cleaned = cbuOrCvu.filter { $0.isNumber }
        return cleaned.count == 22
    }
    
    // CONCEPTO: computed property con lógica de negocio
    var displayIdentifier: String {
        alias ?? formatCBUCVU()
    }
    
    private func formatCBUCVU() -> String {
        let cleaned = cbuOrCvu.filter { $0.isNumber }
        guard cleaned.count == 22 else { return cbuOrCvu }
        // Formato: XXXX-XXXX XXXX-XXXX XXXX-XX
        return "\(cleaned.prefix(4))-\(cleaned.dropFirst(4).prefix(4)) \(cleaned.dropFirst(8).prefix(4))-\(cleaned.dropFirst(12).prefix(4)) \(cleaned.dropFirst(16).prefix(4))-\(cleaned.dropFirst(20))"
    }
    
    init(
        id: UUID = UUID(),
        recipientName: String,
        cbuOrCvu: String,
        alias: String? = nil,
        isMonederitoUser: Bool = false
    ) {
        self.id = id
        self.recipientName = recipientName
        self.cbuOrCvu = cbuOrCvu
        self.alias = alias
        self.isMonederitoUser = isMonederitoUser
    }
}

// MARK: - Recarga de celular

enum PhoneCarrier: String, CaseIterable, Codable, Identifiable {
    case claro   = "Claro"
    case personal = "Personal"
    case movistar = "Movistar"
    case tuenti  = "Tuenti"
    
    var id: String { rawValue }
    
    var logo: String {
        switch self {
        case .claro:    return "📱"
        case .personal: return "📲"
        case .movistar: return "📳"
        case .tuenti:   return "📴"
        }
    }
    
    // Montos predefinidos por compañía
    var presetAmounts: [Double] {
        [200, 500, 1000, 2000]
    }
}

// MARK: - Servicios

enum ServiceType: String, CaseIterable, Codable, Identifiable {
    case electricity = "Luz"
    case water       = "Agua"
    case gas         = "Gas"
    case internet    = "Internet / TV"
    case phone       = "Telefonía"
    case expenses    = "Expensas"
    case rent        = "Alquiler"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .electricity: return "⚡"
        case .water:       return "💧"
        case .gas:         return "🔥"
        case .internet:    return "📡"
        case .phone:       return "📱"
        case .expenses:    return "🏢"
        case .rent:        return "🏠"
        }
    }
    
    var providers: [String] {
        switch self {
        case .electricity: return ["EDESUR", "EDENOR"]
        case .water:       return ["AySA"]
        case .gas:         return ["Metrogas", "Naturgy"]
        case .internet:    return ["Fibertel", "Telecentro", "Personal Flow", "Claro"]
        case .phone:       return ["Claro", "Personal", "Movistar"]
        case .expenses:    return ["Administración propia"]
        case .rent:        return ["Propietario directo"]
        }
    }
}
