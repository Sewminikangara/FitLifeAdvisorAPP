//
//  AuthenticationManagerTests.swift
//  FitLifeAdvisorAppTests
//
//. unit tests for authentication 
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
        // Clear any existing UserDefaults
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
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated initially")
        XCTAssertNil(authManager.authenticationError, "Authentication error should be nil initially")
        XCTAssertTrue(authManager.errorMessage.isEmpty, "Error message should be empty initially")
        XCTAssertFalse(authManager.isLoading, "Should not be loading initially")
        XCTAssertNil(authManager.user, "User should be nil initially")
        XCTAssertNil(authManager.currentUser, "Current user should be nil initially")
        XCTAssertFalse(authManager.showBiometricSetupAlert, "Should not show biometric setup alert initially")
    }
    
    // Sign In Tests
    
    func testSignInSuccess() {
        // Given
        let email = "user@example.com"
        let password = "123456"
        let expectation = expectation(description: "signIn")

        // When
        authManager.signIn(email: email, password: password)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(self.authManager.isAuthenticated, "Should be authenticated after successful sign in")
            XCTAssertNil(self.authManager.authenticationError, "Authentication error should be nil after success")
            XCTAssertNotNil(self.authManager.currentUser, "Current user should not be nil after sign in")
            XCTAssertEqual(self.authManager.currentUser?.email, email, "User email should match")
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "wasAuthenticated"), "Should save authentication state")
            XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail"), email, "Should save user email")
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
        // Given
        let email = "newuser@example.com"
        let password = "password123"
        let name = "Test User"
        let expectation = expectation(description: "signUp")

        // When
        authManager.signUp(email: email, password: password, name: name)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertTrue(self.authManager.isAuthenticated, "Should be authenticated after successful sign up")
            XCTAssertNotNil(self.authManager.currentUser, "Current user should not be nil after sign up")
            XCTAssertEqual(self.authManager.currentUser?.email, email, "User email should match")
            XCTAssertEqual(self.authManager.currentUser?.name, name, "User name should match")
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "wasAuthenticated"), "Should save authentication state")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSignUpWithFullNameMethod() {
        // Given
        let fullName = "John Doe"
        let email = "john@example.com"
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
        // Given & When
        let biometricType = authManager.checkBiometricAvailability()
        
        // Then
        XCTAssertTrue([BiometricType.faceID, BiometricType.touchID, BiometricType.none].contains(biometricType), 
                     "Should return a valid biometric type")
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
        // Given
        let email = "stored@example.com"
        let name = "Stored User"
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(name, forKey: "userName")
        
        // When
        let newAuthManager = AuthenticationManager()
        
        // Then
        XCTAssertNotNil(newAuthManager.user, "Should load user from storage")
        XCTAssertEqual(newAuthManager.user?.email, email, "Should load correct email")
        XCTAssertEqual(newAuthManager.user?.name, name, "Should load correct name")
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
        // Given
        authManager.isAuthenticated = true
        authManager.user = User(email: "test@example.com", name: "Test")
        authManager.authenticationError = "Some error"
        authManager.errorMessage = "Some message"
        UserDefaults.standard.set(true, forKey: "wasAuthenticated")
        
        // When
        authManager.logout()
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated after logout")
        XCTAssertNil(authManager.authenticationError, "Authentication error should be nil after logout")
        XCTAssertTrue(authManager.errorMessage.isEmpty, "Error message should be empty after logout")
        XCTAssertNil(authManager.user, "User should be nil after logout")
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "wasAuthenticated"), "Should clear authentication state")
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
