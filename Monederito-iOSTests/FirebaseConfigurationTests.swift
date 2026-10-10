import XCTest
@testable import Monederito_iOS

@MainActor
final class FirebaseConfigurationTests: XCTestCase {
    private let bundleID = "com.example.wallet"
    private let clientID = "example.apps.googleusercontent.com"
    private var valid: [String: Any] {
        ["GOOGLE_APP_ID": "1:123:ios:example", "GCM_SENDER_ID": "123", "API_KEY": "fixture",
         "PROJECT_ID": "sandbox-fixture", "BUNDLE_ID": bundleID, "CLIENT_ID": clientID]
    }

    func testMatchingSandboxConfigurationIsAccepted() throws {
        try FirebaseConfigurationValidator.validate(valid, bundleID: bundleID, googleClientID: clientID)
    }

    func testPlistFromAnotherAppIsRejected() {
        XCTAssertThrowsError(try FirebaseConfigurationValidator.validate(valid, bundleID: "other.app", googleClientID: clientID))
        XCTAssertThrowsError(try FirebaseConfigurationValidator.validate(valid, bundleID: bundleID, googleClientID: "other.client"))
    }

    func testIncompleteFirebaseConfigurationIsRejectedBeforeSDKInitialization() {
        for key in ["GOOGLE_APP_ID", "GCM_SENDER_ID", "API_KEY", "PROJECT_ID", "BUNDLE_ID"] {
            var incomplete = valid
            incomplete.removeValue(forKey: key)
            XCTAssertThrowsError(try FirebaseConfigurationValidator.validate(incomplete, bundleID: bundleID, googleClientID: clientID), key)
        }
        var wrongPlatform = valid
        wrongPlatform["GOOGLE_APP_ID"] = "1:123:android:example"
        XCTAssertThrowsError(try FirebaseConfigurationValidator.validate(wrongPlatform, bundleID: bundleID, googleClientID: clientID))
    }

    func testFirebasePlistWithoutOAuthClientUsesIndependentGoogleConfiguration() throws {
        var withoutOAuth = valid
        withoutOAuth.removeValue(forKey: "CLIENT_ID")
        try FirebaseConfigurationValidator.validate(withoutOAuth, bundleID: bundleID, googleClientID: clientID)
    }
}
