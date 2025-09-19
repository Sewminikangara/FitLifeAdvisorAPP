//
//  AuthenticationManagerTests.swift
//  FitLifeAdvisorAppTests
//
//  Unit tests for authentication
//

import XCTest
import LocalAuthentication
@testable import FitLifeAdvisorApp

@MainActor
final class AuthenticationManagerTests: XCTestCase {
    // Test Properties
    var authManager: AuthenticationManager!
    
    //Setup & Teardown
    override func setUpWithError() throws {
        super.setUp()
        authManager = AuthenticationManager()
        // Clear UserDefaults for test isolation
        UserDefaults.standard.removeObject(forKey: "wasAuthenticated")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
    }
    override func tearDownWithError() throws {
        authManager = nil
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "wasAuthenticated")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        super.tearDown()
    }
    
    // Initialization Tests
    func testAuthenticationManagerInitialization() {
        // Check initial state
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.authenticationError)
        XCTAssertTrue(authManager.errorMessage.isEmpty)
        XCTAssertFalse(authManager.isLoading)
        XCTAssertNil(authManager.user)
        XCTAssertNil(authManager.currentUser)
        XCTAssertFalse(authManager.showBiometricSetupAlert)
    }
    
    // Sign In Tests
    func testSignInSuccess() {
        // Simulate valid sign in
        let email = "user@example.com"
        let password = "123456"
        let expectation = expectation(description: "signIn")
        authManager.signIn(email: email, password: password)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(self.authManager.isAuthenticated)
            XCTAssertNil(self.authManager.authenticationError)
            XCTAssertNotNil(self.authManager.currentUser)
            XCTAssertEqual(self.authManager.currentUser?.email, email)
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "wasAuthenticated"))
            XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail"), email)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testSignInFailure() {
        // Given
        let invalidEmail = "invalid"
        let shortPassword = "123"
        let expectation = expectation(description: "signInFail")

        // When
        authManager.signIn(email: invalidEmail, password: shortPassword)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isAuthenticated, "Should not be authenticated after failed sign in")
            XCTAssertFalse(self.authManager.errorMessage.isEmpty, "Error message should not be empty after failure")
            XCTAssertNil(self.authManager.currentUser, "Current user should be nil after failed sign in")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignInWithValidEmailInvalidPassword() {
        // Given  
        let validEmail = "test@example.com"
        let invalidPassword = "123" // Too short
        let expectation = expectation(description: "signInInvalidPassword")

        // When
        authManager.signIn(email: validEmail, password: invalidPassword)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isAuthenticated)
            XCTAssertEqual(self.authManager.errorMessage, "Invalid email or password")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    // Sign Up Tests
    func testSignUpSuccess() {
        // Simulate valid sign up
        let email = "newuser@example.com"
        let password = "password123"
        let name = "Test User"
        let expectation = expectation(description: "signUp")
        authManager.signUp(email: email, password: password, name: name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(self.authManager.isAuthenticated)
            XCTAssertNotNil(self.authManager.currentUser)
            XCTAssertEqual(self.authManager.currentUser?.email, email)
            XCTAssertEqual(self.authManager.currentUser?.name, name)
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "wasAuthenticated"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignUpWithFullNameMethod() {
        // Given
        let fullName = "sewminiK"
        let email = "sewminiK@example.com"
        let password = "password123"
        let expectation = expectation(description: "signUpFullName")

        // When
        authManager.signUp(fullName: fullName, email: email, password: password)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(self.authManager.isAuthenticated)
            XCTAssertEqual(self.authManager.currentUser?.name, fullName)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSignUpFailure() {
        // Given
        let invalidEmail = "invalid-email"
        let shortPassword = "123"
        let emptyName = ""
        let expectation = expectation(description: "signUpFail")

        // When
        authManager.signUp(email: invalidEmail, password: shortPassword, name: emptyName)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isAuthenticated, "Should not be authenticated after failed sign up")
            XCTAssertFalse(self.authManager.errorMessage.isEmpty, "Error message should not be empty after failure")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    //  Biometric Authentication Tests
    func testBiometricTypeDetection() {
        // Check biometric type
        let biometricType = authManager.checkBiometricAvailability()
        XCTAssertTrue([BiometricType.faceID, BiometricType.touchID, BiometricType.none].contains(biometricType))
    }
    
    func testEnableBiometricAuthentication() {
        // Given
        let initialState = authManager.isBiometricEnabled
        
        // When
        authManager.enableBiometricAuthentication()
        
        // Then
        if authManager.checkBiometricAvailability() != .none {
            XCTAssertTrue(authManager.isBiometricEnabled, "Should enable biometric authentication when available")
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "biometricEnabled"), "Should save biometric enabled state")
        } else {
            XCTAssertEqual(authManager.isBiometricEnabled, initialState, "Should not change state when biometric unavailable")
        }
    }
    
    func testDisableBiometricAuthentication() {
        // Given
        authManager.enableBiometricAuthentication()
        
        // When
        authManager.disableBiometricAuthentication()
        
        // Then
        XCTAssertFalse(authManager.isBiometricEnabled, "Should disable biometric authentication")
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "biometricEnabled"), "Should save disabled state")
    }
    
    func testIsBiometricEnabledComputedProperty() {
        // Given
        UserDefaults.standard.set(true, forKey: "biometricEnabled")
        
        // When & Then
        if authManager.checkBiometricAvailability() != .none {
            XCTAssertTrue(authManager.isBiometricEnabled, "Should return true when enabled and available")
        } else {
            XCTAssertFalse(authManager.isBiometricEnabled, "Should return false when not available")
        }
        
        // Given
        UserDefaults.standard.set(false, forKey: "biometricEnabled")
        
        // When & Then
        XCTAssertFalse(authManager.isBiometricEnabled, "Should return false when disabled")
    }
    
    // User Data Management Tests
    func testLoadUserFromStorage() {
        // Simulate loading user from UserDefaults
        let email = "stored@example.com"
        let name = "Stored User"
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(name, forKey: "userName")
        let newAuthManager = AuthenticationManager()
        XCTAssertNotNil(newAuthManager.user)
        XCTAssertEqual(newAuthManager.user?.email, email)
        XCTAssertEqual(newAuthManager.user?.name, name)
    }
    
    func testLoadUserFromStorageWithMissingName() {
        // Given
        let email = "stored@example.com"
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        // When
        let newAuthManager = AuthenticationManager()
        
        // Then
        XCTAssertNotNil(newAuthManager.user, "Should load user from storage")
        XCTAssertEqual(newAuthManager.user?.email, email, "Should load correct email")
        XCTAssertEqual(newAuthManager.user?.name, "User", "Should use default name when missing")
    }
    
    // Biometric Setup Tests
    func testConfirmBiometricSetup() {
        // Given
        authManager.showBiometricSetupAlert = true
        
        // When
        authManager.confirmBiometricSetup()
        
        // Then
        XCTAssertFalse(authManager.showBiometricSetupAlert, "Should hide biometric setup alert")
        if authManager.checkBiometricAvailability() != .none {
            XCTAssertTrue(authManager.isBiometricEnabled, "Should enable biometric authentication")
        }
    }
    
    func testSkipBiometricSetup() {
        // Given
        authManager.showBiometricSetupAlert = true
        
        // When
        authManager.skipBiometricSetup()
        
        // Then
        XCTAssertFalse(authManager.showBiometricSetupAlert, "Should hide biometric setup alert")
    }
    
    // Logout Tests
    func testLogout() {
        // Simulate logout
        authManager.isAuthenticated = true
        authManager.user = User(email: "test@example.com", name: "Test")
        authManager.authenticationError = "Some error"
        authManager.errorMessage = "Some message"
        UserDefaults.standard.set(true, forKey: "wasAuthenticated")
        authManager.logout()
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.authenticationError)
        XCTAssertTrue(authManager.errorMessage.isEmpty)
        XCTAssertNil(authManager.user)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "wasAuthenticated"))
    }
    
    func testSignOut() {
        // Given
        authManager.isAuthenticated = true
        authManager.user = User(email: "test@example.com", name: "Test")
        
        // When
        authManager.signOut()
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated, "SignOut should behave same as logout")
        XCTAssertNil(authManager.user, "User should be nil after sign out")
    }
    
    // BiometricType Enum Tests
    func testBiometricTypeEnum() {
        // Given & When & Then
        let faceID = BiometricType.faceID
        let touchID = BiometricType.touchID
        let none = BiometricType.none
        
        XCTAssertNotEqual(faceID, touchID, "Face ID should not equal Touch ID")
        XCTAssertNotEqual(faceID, none, "Face ID should not equal none")
        XCTAssertNotEqual(touchID, none, "Touch ID should not equal none")
    }
    
    // Loading State Tests
    func testLoadingStateDuringSignIn() {
        // Given
        let expectation = expectation(description: "loadingState")
        
        // When
        authManager.signIn(email: "test@example.com", password: "password123")
        
        // Then
        XCTAssertTrue(authManager.isLoading, "Should be loading immediately after sign in call")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isLoading, "Should not be loading after completion")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testLoadingStateDuringSignUp() {
        // Given
        let expectation = expectation(description: "loadingStateSignUp")
        
        // When
        authManager.signUp(email: "test@example.com", password: "password123", name: "Test")
        
        // Then
        XCTAssertTrue(authManager.isLoading, "Should be loading immediately after sign up call")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isLoading, "Should not be loading after completion")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // Edge Cases Tests
    func testSignInWithEmptyCredentials() {
        // Given
        let expectation = expectation(description: "emptyCredentials")
        
        // When
        authManager.signIn(email: "", password: "")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isAuthenticated)
            XCTAssertFalse(self.authManager.errorMessage.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignUpWithEmptyName() {
        // Given
        let expectation = expectation(description: "emptyName")
        
        // When
        authManager.signUp(email: "test@example.com", password: "password123", name: "")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(self.authManager.isAuthenticated)
            XCTAssertEqual(self.authManager.errorMessage, "Please check your information and try again")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // Performance Tests
    func testAuthenticationPerformance() {
        measure {
            let expectation = expectation(description: "authPerformance")
            authManager.signIn(email: "test@example.com", password: "password123")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 2.0)
        }
    }
}
