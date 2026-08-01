//
//  FirebaseAnalyticsService.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/07/2026.
//

import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsServiceProtocol {
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    func setUserID(_ id: String?) {
        Analytics.setUserID(id)
    }
    
    func logScreenView(_ screenName: String) {
        Analytics.logEvent("screen_view", parameters: [
            "screen_name": screenName
        ])
    }
}