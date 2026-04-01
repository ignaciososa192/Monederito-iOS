//
//  DeepLinkHandler.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 01/04/2026.
//

import Foundation

// CONCEPTO: Deep Link — URL o payload que abre una pantalla específica
// Cuando Elena toca la notificación, la app debe abrir
// directamente el AlertDetailView de esa alerta, no el Dashboard.

enum DeepLink: Equatable {
    case riskAlert(alertID: UUID)
    case transaction(transactionID: UUID)
    case settings
    case beneficiary(accountID: UUID)
    
    // CONCEPTO: failable init — puede fallar y retornar nil
    // Parseamos el userInfo de la notificación para construir el DeepLink
    init?(from userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return nil }
        
        switch type {
        case "riskAlert":
            guard let alertIDString = userInfo["alertID"] as? String,
                  let alertID = UUID(uuidString: alertIDString) else { return nil }
            self = .riskAlert(alertID: alertID)
            
        case "transaction":
            guard let transactionIDString = userInfo["transactionID"] as? String,
                  let transactionID = UUID(uuidString: transactionIDString) else { return nil }
            self = .transaction(transactionID: transactionID)
            
        default:
            return nil
        }
    }
}
