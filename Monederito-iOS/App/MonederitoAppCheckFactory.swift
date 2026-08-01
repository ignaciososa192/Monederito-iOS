//
//  MonederitoAppCheckFactory.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 01/08/2026.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

class MonederitoAppCheckFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        // Use DeviceCheckProvider for debug builds (works in simulator)
        return DeviceCheckProvider(app: app)
        #else
        // Use AppAttestProvider for release builds (requires Apple Developer account)
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app)
        }
        #endif
    }
}
