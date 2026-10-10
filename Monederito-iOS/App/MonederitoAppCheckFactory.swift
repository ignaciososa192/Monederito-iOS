import DeviceCheck
import FirebaseCore
import FirebaseAppCheck

/// Release uses device attestation. The Debug factory is installed before Firebase configure.
final class MonederitoAppCheckFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        if DCAppAttestService.shared.isSupported {
            return AppAttestProvider(app: app)
        }
        if DCDevice.current.isSupported {
            return DeviceCheckProvider(app: app)
        }
        // A Release simulator cannot attest; never silently use a Debug token.
        return nil
    }
}
