import XCTest
import Supabase
@testable import Monederito_iOS

@MainActor
final class SupabaseRegistrationTests: XCTestCase {
    private func repository() -> SupabaseAuthRepository {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [AuthFixtureProtocol.self]
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://auth-fixture.invalid")!,
            supabaseKey: "test-key",
            options: .init(
                auth: .init(storage: EmptyAuthStorage(), autoRefreshToken: false),
                global: .init(session: URLSession(configuration: config))
            )
        )
        return SupabaseAuthRepository(client: client)
    }

    func testSignupWithoutSessionDoesNotAccessProfiles() async throws {
        let result = try await repository().signUp(email: "wallet@example.com", password: "sandbox-password", fullName: "Wallet", role: .benefactor, phone: "1234567890")
        guard case .confirmationRequired(let email) = result else { return XCTFail("Expected email confirmation") }
        XCTAssertEqual(email, "wallet@example.com")
    }

    func testSignupWithSessionPreservesExistingProfileRole() async throws {
        let result = try await repository().signUp(email: "immediate@example.com", password: "sandbox-password", fullName: "New Name", role: .benefactor, phone: "1234567890")
        guard case .authenticated(let user) = result else { return XCTFail("Expected authenticated registration") }
        XCTAssertEqual(user.role, .beneficiary)
        XCTAssertEqual(user.fullName, "Persisted Name")
    }

    func testLoginPreservesPersistedBeneficiaryRole() async throws {
        let user = try await repository().signIn(email: "wallet@example.com", password: "sandbox-password")
        XCTAssertEqual(user.role, .beneficiary)
        XCTAssertEqual(user.fullName, "Persisted Name")
    }
}

private struct EmptyAuthStorage: AuthLocalStorage {
    func store(key: String, value: Data) throws {}
    func retrieve(key: String) throws -> Data? { nil }
    func remove(key: String) throws {}
}

private final class AuthFixtureProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let authUser = """
        {"id":"11111111-1111-1111-1111-111111111111","app_metadata":{},"user_metadata":{},"aud":"authenticated","email":"wallet@example.com","created_at":"2026-10-09T12:00:00Z","updated_at":"2026-10-09T12:00:00Z"}
        """
        let expiresAt = Date().addingTimeInterval(3600).timeIntervalSince1970
        let path = request.url!.path
        let payload: String
        var bodyData = request.httpBody ?? Data()
        if let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }
            var buffer = [UInt8](repeating: 0, count: 1024)
            while stream.hasBytesAvailable {
                let count = stream.read(&buffer, maxLength: buffer.count)
                guard count > 0 else { break }
                bodyData.append(contentsOf: buffer.prefix(count))
            }
        }
        let body = String(decoding: bodyData, as: UTF8.self)
        if path == "/auth/v1/signup", !body.contains("immediate@example.com") {
            payload = authUser
        } else if path == "/auth/v1/token" || path == "/auth/v1/signup" {
            payload = "{\"access_token\":\"fixture\",\"token_type\":\"bearer\",\"expires_in\":3600,\"expires_at\":\(expiresAt),\"refresh_token\":\"fixture\",\"user\":\(authUser)}"
        } else if path == "/rest/v1/profiles", request.httpMethod == "GET" {
            payload = """
            {"id":"11111111-1111-1111-1111-111111111111","full_name":"Persisted Name","email":"wallet@example.com","role":"beneficiary"}
            """
        } else {
            // Reject unexpected requests, including profile writes on login/confirmation.
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(payload.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
