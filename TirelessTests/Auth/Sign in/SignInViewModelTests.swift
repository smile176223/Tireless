//
//  SignInViewModelTests.swift
//  TirelessTests
//
//  Created by Hao on 2023/11/23.
//

import XCTest
import Tireless

final class SignInViewModelTests: XCTestCase {

    func test_singInWithFirebase_getErrorMessage() {
        let spy = FirebaseAuthManagerSpy()
        let sut = SignInViewModel(firebaseAuth: spy)
        let email = "any email"
        let password = "any password"
        let error: AuthError = .customError("any error")
        
        sut.signInWithFirebase(email: email, password: password)
        spy.completeSignInWithFirebase(with: error)
        
        XCTAssertEqual(spy.messages, [.signInWithFirebase(email: email, password: password)])
        XCTAssertNil(sut.authData)
        expect(sut.authError, with: error)
    }
    
    func test_signInWithFirebase_successfullyGetAuthData() {
        let spy = FirebaseAuthManagerSpy()
        let sut = SignInViewModel(firebaseAuth: spy)
        let email = "any email"
        let password = "any password"
        let data = AuthData(email: email, userId: password)
        
        sut.signInWithFirebase(email: email, password: password)
        spy.completeSignInWithFirebaseSuccessfully(with: data)
        
        XCTAssertEqual(spy.messages, [.signInWithFirebase(email: email, password: password)])
        XCTAssertNil(sut.authError)
        XCTAssertEqual(sut.authData, data)
    }
    
    // MARK: - Helpers
    
    private func expect(_ receivedAuthError: AuthError?, with expectedAuthError: AuthError, file: StaticString = #filePath, line: UInt = #line) {
        guard let receivedAuthError = receivedAuthError else {
            XCTFail("Expected error not nil", file: file, line: line)
            return
        }
        
        switch (receivedAuthError, expectedAuthError) {
        case (.unknown, .unknown):
            break
        case let (.customError(receivedMessage), .customError(expectedMessage)):
            XCTAssertEqual(receivedMessage, expectedMessage, file: file, line: line)
            
        case let (.appleError(receivedError as NSError), .appleError(expectedError as NSError)):
            XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
            XCTAssertEqual(receivedError.domain, expectedError.domain, file: file, line: line)
            
        case let (.firebaseError(receivedError as NSError), .firebaseError(expectedError as NSError)):
            XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)
            XCTAssertEqual(receivedError.domain, expectedError.domain, file: file, line: line)
            
        default:
            XCTFail("Expected to get \(expectedAuthError), but got \(receivedAuthError) instead.")
            
        }
    }

}
