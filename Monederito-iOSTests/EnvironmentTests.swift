import XCTest
import FirebaseCore
@testable import Monederito_iOS

@MainActor
final class EnvironmentTests: XCTestCase {
    func testMockRunsWithoutServiceConfiguration() throws {
        let config = try AppConfiguration(info: ["MONEDERITO_ENVIRONMENT": "mock"], hasFirebaseConfiguration: false)
        XCTAssertEqual(config.environment, .mock)

        let container = DependencyContainer(environment: .mock)
        XCTAssertTrue(container.authRepository is MockAuthRepository)
        XCTAssertTrue(container.transactionRepository is MockTransactionRepository)
        XCTAssertTrue(container.operationsRepository is MockOperationsRepository)
        XCTAssertTrue(container.analyticsService is MockAnalyticsService)
    }

    func testHostedMockAppDoesNotInitializeFirebase() {
        XCTAssertEqual(AppConfiguration.current?.environment, .mock)
        XCTAssertNil(AppConfiguration.startupError)
        XCTAssertNil(FirebaseApp.app())
    }

    func testUnknownEnvironmentFailsInsteadOfSelectingABackend() {
        for environment in ["", "production", "$(MONEDERITO_ENVIRONMENT)"] {
            XCTAssertThrowsError(try AppConfiguration(info: ["MONEDERITO_ENVIRONMENT": environment], hasFirebaseConfiguration: false))
        }
    }

    func testSandboxRequiresCompleteConfiguration() throws {
        let complete: [String: Any] = [
            "MONEDERITO_ENVIRONMENT": "sandbox",
            "SUPABASE_URL": "https://example.supabase.co",
            "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_example",
            "GIDClientID": "example.apps.googleusercontent.com"
        ]
        XCTAssertEqual(try AppConfiguration(info: complete, hasFirebaseConfiguration: true).environment, .sandbox)
        XCTAssertThrowsError(try AppConfiguration(info: complete, hasFirebaseConfiguration: false))
        for key in ["SUPABASE_URL", "SUPABASE_PUBLISHABLE_KEY", "GIDClientID"] {
            var missing = complete
            missing.removeValue(forKey: key)
            XCTAssertThrowsError(try AppConfiguration(info: missing, hasFirebaseConfiguration: true))
        }
        var invalidURL = complete
        invalidURL["SUPABASE_URL"] = "http://example.supabase.co"
        XCTAssertThrowsError(try AppConfiguration(info: invalidURL, hasFirebaseConfiguration: true))
    }

    func testMockAuthenticationWithoutNetwork() async throws {
        let container = DependencyContainer(environment: .mock)
        let user = try await container.authRepository.signIn(email: "elena@example.com", password: "sandbox-password")
        XCTAssertEqual(user.role, .benefactor)
        do {
            _ = try await container.authRepository.signIn(email: "", password: "")
            XCTFail("Empty credentials must be rejected")
        } catch let error as AppError {
            XCTAssertEqual(error.localizedDescription, AppError.invalidCredentials.localizedDescription)
        }
    }
}
