//
//  NotificationDelegate.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 01/04/2026.
//

import UserNotifications
import SwiftUI

// CONCEPTO: UNUserNotificationCenterDelegate
// Este delegate recibe los eventos de notificaciones:
// - Cuando el usuario toca un botón de acción (Aprobar/Denegar)
// - Cuando el usuario toca el cuerpo de la notificación
// - Cuando llega una notificación con la app en primer plano

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Referencia al AppState para resolver alertas directamente
    // CONCEPTO: weak var — referencia débil para evitar retain cycle
    // Si AppState se libera, esta referencia se vuelve nil automáticamente
    // en lugar de mantener vivo un objeto que ya no existe.
    weak var appState: AppState?
    
    // Repositorio para resolver alertas sin abrir la app
    var transactionRepository: (any TransactionRepositoryProtocol)?
    
    // MARK: - Notificación llega con la app en primer plano
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Mostramos la notificación aunque la app esté abierta
        // (útil para cuando Lucas usa la app y llega la alerta)
        completionHandler([.banner, .badge, .sound])
    }
    
    // MARK: - Usuario interactúa con la notificación
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Extraer el alertID del payload
        guard let alertIDString = userInfo["alertID"] as? String,
              let alertID = UUID(uuidString: alertIDString) else {
            completionHandler()
            return
        }
        
        switch response.actionIdentifier {
            
        case NotificationManager.ActionID.approve:
            // APROBAR desde pantalla de bloqueo — sin abrir la app
            Task {
                try? await transactionRepository?.resolveAlert(
                    alertID: alertID,
                    status: AlertStatus.approved
                )
                // Notificar al beneficiario
                await NotificationManager.shared.scheduleAlertResolution(
                    approved: true,
                    merchant: userInfo["merchant"] as? String ?? "",
                    amount: "$\(userInfo["amount"] as? Double ?? 0)"
                )
            }
            
        case NotificationManager.ActionID.deny:
            // DENEGAR desde pantalla de bloqueo — sin abrir la app
            Task {
                try? await transactionRepository?.resolveAlert(
                    alertID: alertID,
                    status: AlertStatus.denied
                )
                await NotificationManager.shared.scheduleAlertResolution(
                    approved: false,
                    merchant: userInfo["merchant"] as? String ?? "",
                    amount: "$\(userInfo["amount"] as? Double ?? 0)"
                )
            }
            
        case NotificationManager.ActionID.view,
             UNNotificationDefaultActionIdentifier:
            // VER DETALLE o tap en el cuerpo → deep link
            let deepLink = DeepLink(from: userInfo)
            Task { @MainActor in
                NotificationManager.shared.pendingDeepLink = deepLink
            }
            
        default:
            break
        }
        
        completionHandler()
    }
}
