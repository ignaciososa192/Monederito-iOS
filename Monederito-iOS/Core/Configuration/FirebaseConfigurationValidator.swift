import Foundation

enum FirebaseConfigurationValidator {
    enum ValidationError: LocalizedError {
        case invalidConfiguration

        var errorDescription: String? {
            "GoogleService-Info.plist está incompleto o corresponde a otra app. Descargalo desde Firebase para el bundle de Monederito y revisá el client ID de Google."
        }
    }

    static func validate(_ info: [String: Any], bundleID: String, googleClientID: String) throws {
        for key in ["GOOGLE_APP_ID", "GCM_SENDER_ID", "API_KEY", "PROJECT_ID", "BUNDLE_ID"] {
            guard let value = info[key] as? String,
                  !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ValidationError.invalidConfiguration
            }
        }
        guard info["BUNDLE_ID"] as? String == bundleID,
              info["CLIENT_ID"] as? String == googleClientID,
              (info["GOOGLE_APP_ID"] as? String)?.contains(":ios:") == true else {
            throw ValidationError.invalidConfiguration
        }
    }
}
