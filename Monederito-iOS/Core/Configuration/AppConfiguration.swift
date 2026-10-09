import Foundation

/// Backend selection is independent of Debug/Release optimization.
struct AppConfiguration {
    enum Environment: String {
        case mock
        case sandbox
    }

    enum ConfigurationError: LocalizedError {
        case invalidEnvironment
        case missingSandboxConfiguration

        var errorDescription: String? {
            switch self {
            case .invalidEnvironment:
                return "El entorno de la app no está configurado. Seleccioná el scheme Monederito-Mock o Monederito-Sandbox."
            case .missingSandboxConfiguration:
                return "Falta la configuración de Sandbox. Revisá Config/Sandbox.local.xcconfig y GoogleService-Info.plist."
            }
        }
    }

    let environment: Environment
    let supabaseURL: String
    let supabaseKey: String
    let googleClientID: String

    init(info: [String: Any], hasFirebaseConfiguration: Bool) throws {
        guard let environment = Environment(rawValue: Self.value("MONEDERITO_ENVIRONMENT", in: info)) else {
            throw ConfigurationError.invalidEnvironment
        }
        self.environment = environment
        supabaseURL = Self.value("SUPABASE_URL", in: info)
        supabaseKey = Self.value("SUPABASE_PUBLISHABLE_KEY", in: info)
        googleClientID = Self.value("GIDClientID", in: info)

        if environment == .sandbox {
            guard let url = URL(string: supabaseURL), url.scheme == "https", url.host != nil,
                  !supabaseKey.isEmpty,
                  googleClientID.hasSuffix(".apps.googleusercontent.com"),
                  hasFirebaseConfiguration else {
                throw ConfigurationError.missingSandboxConfiguration
            }
        }
    }

    private static func value(_ key: String, in info: [String: Any]) -> String {
        let value = (info[key] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.contains("$(") ? "" : value
    }

    private static let startup: Result<AppConfiguration, Error> = Result {
        try AppConfiguration(
            info: Bundle.main.infoDictionary ?? [:],
            hasFirebaseConfiguration: Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
        )
    }

    static var current: AppConfiguration? { try? startup.get() }
    static var startupError: String? {
        if case .failure(let error) = startup { return error.localizedDescription }
        return nil
    }
}
