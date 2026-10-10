import FirebaseAppCheck
import FirebaseCrashlytics
import Foundation

/// Explicit Xcode launch probes, unavailable in Release and never run in Mock.
enum FirebaseDiagnostics {
    static func runIfRequested(arguments: [String] = ProcessInfo.processInfo.arguments) {
        #if DEBUG
        guard AppConfiguration.current?.environment == .sandbox else { return }
        if arguments.contains("--monederito-verify-firebase") {
            let error = NSError(domain: "Monederito.Sandbox.W03", code: 3,
                                userInfo: [NSLocalizedDescriptionKey: "W03 sandbox non-fatal verification"])
            Crashlytics.crashlytics().record(error: error)
            print("W03: Crashlytics non-fatal queued; relaunch to upload and verify in console.")
            AppCheck.appCheck().token(forcingRefresh: true) { token, error in
                // Never log the token or the SDK error description, which may contain credentials.
                if let token, error == nil, !token.token.isEmpty {
                    print("W03: App Check token exchange succeeded.")
                } else {
                    print("W03: App Check token exchange failed. Check Debug token registration in Firebase.")
                }
            }
        }
        if arguments.contains("--monederito-test-crash") {
            fatalError("W03 sandbox Crashlytics verification")
        }
        #endif
    }
}
