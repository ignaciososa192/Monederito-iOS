//
//  AlertStatus.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

// Este enum modela el ciclo de vida de una alerta de transacción riesgosa
// Viene directo del Task Flow del PDF: detectar → notificar → revisar → aprobar/denegar

enum AlertStatus: String, Codable {
    case pending  = "Pendiente"   // Esperando respuesta del benefactor
    case approved = "Aprobado"    // Benefactor aprobó la operación
    case denied   = "Denegado"    // Benefactor bloqueó la operación
    case expired  = "Expirado"    // Pasó el tiempo límite sin respuesta
    
    var isPending: Bool { self == .pending }
}
