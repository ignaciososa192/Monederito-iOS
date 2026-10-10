import XCTest
@testable import Monederito_iOS

@MainActor
final class AuthRegistrationTests: XCTestCase {
    func testConfirmationRequiredDoesNotAuthenticateAndClearsPasswords() async {
        let state = AppState()
        let model = AuthViewModel()
        model.email = "wallet@example.com"
        model.password = "sandbox-password"
        model.confirmPassword = model.password
        await model.signUp(using: RegistrationRepository(result: .confirmationRequired(email: model.email)), appState: state)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.currentUser)
        XCTAssertEqual(model.confirmationEmail, "wallet@example.com")
        XCTAssertEqual(model.password, "")
        XCTAssertEqual(model.confirmPassword, "")
        XCTAssertFalse(model.isLoading)
        XCTAssertNil(model.errorMessage)
    }

    func testRegistrationWithSessionUsesReturnedProfile() async {
        let state = AppState()
        let model = AuthViewModel()
        model.selectedRole = .benefactor
        let user = MockData.beneficiaryUser
        await model.signUp(using: RegistrationRepository(result: .authenticated(user)), appState: state)
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(state.currentUser?.id, user.id)
        XCTAssertEqual(state.currentUser?.role, .beneficiary)
        XCTAssertNil(model.confirmationEmail)
    }

    func testFailedRegistrationDoesNotAuthenticate() async {
        let state = AppState()
        let model = AuthViewModel()
        await model.signUp(using: RegistrationRepository(result: nil), appState: state)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.currentUser)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
    }
}

private final class RegistrationRepository: AuthRepositoryProtocol {
    let result: SignUpResult?
    init(result: SignUpResult?) { self.result = result }
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> SignUpResult {
        guard let result else { throw AppError.networkUnavailable }
        return result
    }
    func signIn(email: String, password: String) async throws -> User { throw AppError.invalidCredentials }
    func signInWithGoogle(role: UserRole?) async throws -> User { throw AppError.invalidCredentials }
    func signOut() async throws {}
    func getCurrentUser() async throws -> User? { nil }
    func resetPassword(email: String) async throws {}
    func updateProfile(_ user: User) async throws -> User { user }
    func enableBiometrics() async throws {}
}
