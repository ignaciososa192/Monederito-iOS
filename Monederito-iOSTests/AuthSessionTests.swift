import XCTest
@testable import Monederito_iOS

@MainActor
final class AuthSessionTests: XCTestCase {
    func testRestoreAndLogoutClearSessionAndRoutes() async throws {
        let repository = MockAuthRepository()
        _ = try await repository.signIn(email: "lucas@example.com", password: "sandbox-password")
        let state = AppState()
        await state.restoreSession(using: repository)
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(state.currentUser?.role, .beneficiary)
        XCTAssertFalse(state.isRestoringSession)
        state.pendingAlertID = UUID()
        state.pendingOperation = .transfer
        await state.signOut(using: repository)
        XCTAssertNil(state.currentUser)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.pendingAlertID)
        XCTAssertNil(state.pendingOperation)
        let restored = try await repository.getCurrentUser()
        XCTAssertNil(restored)
    }

    func testRestoreFailureIsVisibleWithoutAuthenticating() async {
        let state = AppState()
        await state.restoreSession(using: SessionRepository())
        XCTAssertNotNil(state.error)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertFalse(state.isRestoringSession)
    }

    func testLateRestoreCannotUndoLogout() async {
        let repository = SessionRepository()
        repository.delayedRestore = true
        let state = AppState()
        let restore = Task { await state.restoreSession(using: repository) }
        while repository.resumeRestore == nil { await Task.yield() }
        await state.signOut(using: repository)
        repository.resumeRestore?.resume(returning: MockData.beneficiaryUser)
        await restore.value
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.currentUser)
    }

    func testRecoveryEventShowsPasswordFormInsteadOfWallet() async {
        let repository = SessionRepository()
        repository.events = [.passwordRecovery]
        let state = AppState()
        state.loginAsBenefactor()
        await state.observeSession(using: repository)
        XCTAssertTrue(state.requiresPasswordUpdate)
        XCTAssertFalse(state.isAuthenticated)
        state.signOut()
        XCTAssertFalse(state.requiresPasswordUpdate)
    }
}

@MainActor
private final class SessionRepository: AuthRepositoryProtocol {
    var delayedRestore = false
    var resumeRestore: CheckedContinuation<User?, Never>?
    var events: [AuthSessionEvent] = []
    func getCurrentUser() async throws -> User? {
        if delayedRestore {
            return await withCheckedContinuation { resumeRestore = $0 }
        }
        throw AppError.networkUnavailable
    }
    func sessionEvents() -> AsyncStream<AuthSessionEvent> {
        AsyncStream { continuation in
            events.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
    func signIn(email: String, password: String) async throws -> User { throw AppError.invalidCredentials }
    func signInWithGoogle(role: UserRole?) async throws -> User { throw AppError.invalidCredentials }
    func signUp(email: String, password: String, fullName: String, role: UserRole, phone: String) async throws -> SignUpResult { throw AppError.invalidCredentials }
    func signOut() async throws {}
    func resetPassword(email: String) async throws {}
    func updateProfile(_ user: User) async throws -> User { user }
    func enableBiometrics() async throws {}
}
