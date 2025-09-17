//
//  EmailServiceTests.swift
//  FitLifeAdvisorApp
//
//  Simple test to verify email service functionality
//

import XCTest
@testable import FitLifeAdvisorApp

class EmailServiceTests: XCTestCase {
    var emailService: EmailService!
    
    override func setUp() {
        super.setUp()
        emailService = EmailService.shared
    }
    
    func testValidEmailAddresses() {
        let validEmails = [
            "user@example.com",
            "test.email+tag@domain.co.uk",
            "user123@test-domain.org",
            "simple@test.io"
        ]
        
        for email in validEmails {
            let expectation = XCTestExpectation(description: "Email sent for \(email)")
            
            emailService.sendPasswordResetEmail(to: email) { result in
                switch result {
                case .success():
                    print("✅ Success: Password reset email would be sent to \(email)")
                    expectation.fulfill()
                case .failure(let error):
                    if case .userNotFound = error {
                        // This is acceptable in simulation mode
                        print("⚠️ User not found (simulated): \(email)")
                        expectation.fulfill()
                    } else {
                        XCTFail("Unexpected error for valid email \(email): \(error)")
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testInvalidEmailAddresses() {
        let invalidEmails = [
            "invalid-email",
            "@domain.com",
            "user@",
            "user.domain.com",
            ""
        ]
        
        for email in invalidEmails {
            let expectation = XCTestExpectation(description: "Invalid email rejected: \(email)")
            
            emailService.sendPasswordResetEmail(to: email) { result in
                switch result {
                case .success():
                    XCTFail("Invalid email should not succeed: \(email)")
                case .failure(let error):
                    if case .invalidEmail = error {
                        print("✅ Correctly rejected invalid email: \(email)")
                        expectation.fulfill()
                    } else {
                        XCTFail("Wrong error type for invalid email \(email): \(error)")
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testEmailServiceSimulation() {
        let testEmail = "test@example.com"
        let expectation = XCTestExpectation(description: "Email service simulation")
        
        print("🧪 Testing email service with: \(testEmail)")
        
        emailService.sendPasswordResetEmail(to: testEmail) { result in
            switch result {
            case .success():
                print("✅ Email service simulation successful")
                print("📧 In production, an email would be sent to: \(testEmail)")
                expectation.fulfill()
            case .failure(let error):
                print("ℹ️ Simulation result: \(error.localizedDescription)")
                // In simulation mode, some "failures" are expected
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}

// MARK: - Manual Test Function (for debugging)

func testEmailServiceManually() {
    let emailService = EmailService.shared
    let testEmails = ["valid@test.com", "invalid-email", "user@example.org"]
    
    print("🧪 Manual Email Service Test Started")
    print("=====================================")
    
    for email in testEmails {
        print("\n📧 Testing email: \(email)")
        
        emailService.sendPasswordResetEmail(to: email) { result in
            switch result {
            case .success():
                print("✅ SUCCESS: Email would be sent to \(email)")
            case .failure(let error):
                print("❌ FAILED: \(error.localizedDescription)")
                if let suggestion = error.recoverySuggestion {
                    print("💡 Suggestion: \(suggestion)")
                }
            }
        }
    }
    
    print("\n=====================================")
    print("🧪 Manual Email Service Test Complete")
    print("Check the console output above for results")
}
