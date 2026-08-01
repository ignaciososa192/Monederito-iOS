//
//  MockAnalyticsService.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/07/2026.
//

import Foundation

final class MockAnalyticsService: AnalyticsServiceProtocol {
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        print("📊 Analytics Event: \(name)")
        if let params = parameters {
            print("   Parameters: \(params)")
        }
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        print("👤 User Property: \(name) = \(value ?? "nil")")
    }
    
    func setUserID(_ id: String?) {
        print("🆔 User ID: \(id ?? "nil")")
    }
    
    func logScreenView(_ screenName: String) {
        print("📱 Screen View: \(screenName)")
    }
}