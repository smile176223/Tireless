//
//  SignInViewModelTests.swift
//  TirelessTests
//
//  Created by Hao on 2023/11/23.
//

import XCTest
import Tireless

final class SignInViewModelTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        undoSideEffect()
    }

    func test_singInWithFirebase_getErrorMessage() throws {
        let spy = FirebaseAuthManagerSpy()
        let sut = SignInViewModel(authServices: spy)
        let email = "any email"
        let password = "any password"
        let error: AuthError = .customError("any error")
        
        sut.email = email
        sut.password = password
        sut.signIn()
        spy.completeSignIn(with: error)
        
        XCTAssertEqual(spy.messages, [.signIn(email: email, password: password)])
        XCTAssertNil(sut.authData)
        expect(sut.authError, with: error)
        try expectKeychain(.authData, data: nil)
    }
    
    func test_signInWithFirebase_successfullyGetAuthData() throws {
        let spy = FirebaseAuthManagerSpy()
        let sut = SignInViewModel(authServices: spy)
        let email = "any email"
        let password = "any password"
        let name = "any name"
        let data = AuthData(email: email, userId: password, name: name)
        
        sut.email = email
        sut.password = password
        sut.signIn()
        spy.completeSignInSuccessfully(with: data)
        
        XCTAssertEqual(spy.messages, [.signIn(email: email, password: password)])
        XCTAssertNil(sut.authError)
        XCTAssertEqual(sut.authData, data)
        try expectKeychain(.authData, data: data)
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
            
        case let (.appleError(receivedError), .appleError(expectedError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        case let (.firebaseError(receivedError), .firebaseError(expectedError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected to get \(expectedAuthError), but got \(receivedAuthError) instead.")
            
        }
    }
    
    private func expectKeychain(_ key: KeychainManager.Key, data: AuthData?, file: StaticString = #filePath, line: UInt = #line) throws {
        let data: AuthData? = try KeychainManager.retrieve(key)
        XCTAssertEqual(data, data, file: file, line: line)
    }
    
    private func undoSideEffect() {
        try? KeychainManager.delete(.authData)
    }
}
