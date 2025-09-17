import XCTest
@testable import FitLifeAdvisorApp

final class AuthenticationManagerTests: XCTestCase {
    func testSignInSuccess() {
        let auth = AuthenticationManager()
        let exp = expectation(description: "signIn")

        auth.signIn(email: "user@example.com", password: "123456")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(auth.isAuthenticated)
            XCTAssertNil(auth.authenticationError)
            XCTAssertNotNil(auth.currentUser)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }

    func testSignInFailure() {
        let auth = AuthenticationManager()
        let exp = expectation(description: "signInFail")

        auth.signIn(email: "invalid", password: "123")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(auth.isAuthenticated)
            XCTAssertFalse(auth.errorMessage.isEmpty)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2.0)
    }
}
