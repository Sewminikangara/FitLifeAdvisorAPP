import XCTest

final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITestMode")
        app.launch()
    }

    func testLoginScreenElementsExist() {
        // Look for common login elements
        let signInButton = app.buttons["Sign In"]
        let forgot = app.buttons["Forgot Password?"]

        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Sign In button should exist")
        XCTAssertTrue(forgot.exists, "Forgot Password link should exist")
    }
}
