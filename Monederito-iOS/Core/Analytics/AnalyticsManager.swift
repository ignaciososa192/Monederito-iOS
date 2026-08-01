//
//  AnalyticsManager.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/07/2026.
//

import Foundation

@Observable
final class AnalyticsManager {
    
    private let analyticsService: AnalyticsServiceProtocol
    
    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - User Events
    
    func trackLogin(method: String) {
        analyticsService.logEvent("login", parameters: ["method": method])
    }
    
    func trackRegistration(role: String) {
        analyticsService.logEvent("registration", parameters: ["role": role])
    }
    
    func trackLogout() {
        analyticsService.logEvent("logout", parameters: nil)
    }
    
    // MARK: - Transaction Events
    
    func trackTransaction(amount: Double, category: String, merchant: String) {
        analyticsService.logEvent("transaction_completed", parameters: [
            "amount": amount,
            "category": category,
            "merchant": merchant
        ])
    }
    
    func trackTransactionBlocked(reason: String, category: String) {
        analyticsService.logEvent("transaction_blocked", parameters: [
            "reason": reason,
            "category": category
        ])
    }
    
    func trackTransactionApproved(alertID: String) {
        analyticsService.logEvent("transaction_approved", parameters: [
            "alert_id": alertID
        ])
    }
    
    // MARK: - Financial Operations
    
    func trackQRPayment(amount: Double, merchant: String) {
        analyticsService.logEvent("qr_payment", parameters: [
            "amount": amount,
            "merchant": merchant
        ])
    }
    
    func trackTransfer(amount: Double, recipient: String) {
        analyticsService.logEvent("transfer", parameters: [
            "amount": amount,
            "recipient": recipient
        ])
    }
    
    func trackPhoneRecharge(amount: Double, carrier: String) {
        analyticsService.logEvent("phone_recharge", parameters: [
            "amount": amount,
            "carrier": carrier
        ])
    }
    
    func trackSUBERecharge(amount: Double) {
        analyticsService.logEvent("sube_recharge", parameters: [
            "amount": amount
        ])
    }
    
    func trackServicePayment(service: String, amount: Double) {
        analyticsService.logEvent("service_payment", parameters: [
            "service": service,
            "amount": amount
        ])
    }
    
    // MARK: - Education Events
    
    func trackLessonStarted(lessonID: String, category: String) {
        analyticsService.logEvent("lesson_started", parameters: [
            "lesson_id": lessonID,
            "category": category
        ])
    }
    
    func trackLessonCompleted(lessonID: String, xpEarned: Int) {
        analyticsService.logEvent("lesson_completed", parameters: [
            "lesson_id": lessonID,
            "xp_earned": xpEarned
        ])
    }
    
    // MARK: - User Settings
    
    func trackBiometricEnabled(enabled: Bool) {
        analyticsService.logEvent("biometric_setting_changed", parameters: [
            "enabled": enabled
        ])
    }
    
    func trackNotificationPermissionChanged(enabled: Bool) {
        analyticsService.logEvent("notification_permission_changed", parameters: [
            "enabled": enabled
        ])
    }
    
    // MARK: - Screen Tracking
    
    func trackScreenView(_ screenName: String) {
        analyticsService.logScreenView(screenName)
    }
    
    // MARK: - User Properties
    
    func setUserRole(_ role: String) {
        analyticsService.setUserProperty(role, forName: "user_role")
    }
    
    func setUserAccountType(_ type: String) {
        analyticsService.setUserProperty(type, forName: "account_type")
    }
    
    func setUserID(_ id: String) {
        analyticsService.setUserID(id)
    }
}
