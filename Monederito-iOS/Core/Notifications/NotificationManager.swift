//
//  NotificationManager.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 01/04/2026.
//

import UserNotifications
import SwiftUI

// CONCEPTO: Singleton para manejar todo lo relacionado a notificaciones
// Es el único punto de contacto entre la app y UNUserNotificationCenter

@Observable
final class NotificationManager {
    
    static let shared = NotificationManager()
    
    var isAuthorized: Bool = false
    var pendingDeepLink: DeepLink? = nil
    
    // MARK: - Identificadores de categorías y acciones
    // CONCEPTO: Las categorías agrupan acciones.
    // iOS muestra estas acciones como botones en la notificación.
    
    enum CategoryID {
        static let riskAlert    = "RISK_ALERT"
        static let transaction  = "TRANSACTION"
    }
    
    enum ActionID {
        static let approve = "APPROVE_ACTION"
        static let deny    = "DENY_ACTION"
        static let view    = "VIEW_ACTION"
    }
    
    private init() { }
    
    // MARK: - Setup
    // Llamar una vez al iniciar la app
    
    func setup() {
        registerCategories()
        checkAuthorizationStatus()
    }
    
    // CONCEPTO: UNNotificationCategory + UNNotificationAction
    // Registramos las categorías con sus acciones ANTES de pedir permiso.
    // iOS las muestra automáticamente cuando llega una notificación
    // con ese categoryIdentifier.
    
    private func registerCategories() {
        
        // Acciones para alertas de riesgo
        let approveAction = UNNotificationAction(
            identifier: ActionID.approve,
            title: "✅ Aprobar",
            options: [.authenticationRequired] // requiere desbloquear el iPhone
        )
        
        let denyAction = UNNotificationAction(
            identifier: ActionID.deny,
            title: "❌ Denegar",
            options: [.authenticationRequired, .destructive]
        )
        
        let viewAction = UNNotificationAction(
            identifier: ActionID.view,
            title: "Ver detalle",
            options: [.foreground] // abre la app
        )
        
        // Categoría de alerta de riesgo con las 3 acciones
        let riskAlertCategory = UNNotificationCategory(
            identifier: CategoryID.riskAlert,
            actions: [denyAction, approveAction, viewAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([riskAlertCategory])
    }
    
    // MARK: - Permisos
    
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            print("Error pidiendo permisos: \(error)")
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Enviar notificaciones locales
    // En producción estas vendrán del servidor Supabase vía APNs.
    // Por ahora las generamos localmente para testear el flujo completo.
    
    func scheduleRiskAlert(_ alert: RiskAlert) async {
        let content = UNMutableNotificationContent()
        
        // Contenido de la notificación
        content.title = "⚠️ Gasto de riesgo detectado"
        content.subtitle = "\(alert.category.emoji) \(alert.merchant) • \(alert.formattedAmount)"
        content.body = alert.educationalTip
        content.sound = .defaultCritical // sonido más llamativo para alertas críticas
        content.badge = 1
        
        // CONCEPTO: userInfo — payload que viaja con la notificación
        // Lo usamos para el deep linking: saber qué alerta abrir
        content.userInfo = [
            "alertID":        alert.id.uuidString,
            "type":           "riskAlert",
            "amount":         alert.amount,
            "merchant":       alert.merchant,
            "beneficiaryID":  alert.beneficiaryID.uuidString
        ]
        
        // Asignamos la categoría — iOS mostrará los botones Aprobar/Denegar
        content.categoryIdentifier = CategoryID.riskAlert
        
        // Trigger inmediato (2 segundos de delay para simular push del servidor)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 2,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "risk-alert-\(alert.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error programando notificación: \(error)")
        }
    }
    
    // Notificación para el beneficiario cuando se resuelve su alerta
    func scheduleAlertResolution(approved: Bool, merchant: String, amount: String) async {
        let content = UNMutableNotificationContent()
        
        if approved {
            content.title = "✅ Operación aprobada"
            content.body = "Tu tutor aprobó el gasto de \(amount) en \(merchant)"
            content.sound = .default
        } else {
            content.title = "❌ Operación bloqueada"
            content.body = "Tu tutor bloqueó el gasto de \(amount) en \(merchant)"
            content.sound = .default
        }
        
        content.userInfo = ["type": "alertResolution", "approved": approved]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "resolution-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // Limpiar badge cuando el usuario entra a la app
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    func sendTestRichNotification() async {
        let testAlert = RiskAlert(
            transactionID: UUID(),
            beneficiaryID: UUID(),
            benefactorID: UUID(),
            amount: 250.0,
            merchant: "Steam",
            category: .gambling,
            createdAt: Date(),
            status: .pending,
            educationalTip: "Los gastos en juegos pueden ser adictivos. Considera establecer un límite mensual para este tipo de compras."
        )
        
        await scheduleRiskAlert(testAlert)
    }
    #endif
}
