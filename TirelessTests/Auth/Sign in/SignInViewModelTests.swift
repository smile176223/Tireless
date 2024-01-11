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
        spy.completeSignInPublisher(with: error)
        
        XCTAssertEqual(spy.messages, [.signInPublisher(email: email, password: password)])
        XCTAssertNil(sut.authData)
        expect(sut.authError, with: error)
        try expectKeychain(.userItem, item: nil)
    }
    
    func test_signInWithFirebase_successfullyFetchUserWithEmptyData() throws {
        let spy = FirebaseAuthManagerSpy()
        let httpSpy = HTTPClientSpy()
        let sut = SignInViewModel(authServices: spy, firestore: httpSpy)
        let email = "any email"
        let password = "any password"
        let name = "any name"
        let data = AuthData(email: email, userId: password, name: name)
        let userItem = UserItem(id: "any id", email: email, name: name, picture: nil)
        
        sut.email = email
        sut.password = password
        sut.signIn()
        spy.completeSignInPublisher(with: data)
        httpSpy.completeGetSuccessfully(with: Data())
        
        XCTAssertEqual(spy.messages, [.signInPublisher(email: email, password: password)])
        XCTAssertEqual(sut.authError, .unknown)
        try expectKeychain(.userItem, item: userItem)
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
    
    private func expectKeychain(_ key: KeychainManager.Key, item: UserItem?, file: StaticString = #filePath, line: UInt = #line) throws {
        let data: UserItem? = try KeychainManager.retrieve(key)
        XCTAssertEqual(data, data, file: file, line: line)
    }
    
    private func undoSideEffect() {
        try? KeychainManager.delete(.userItem)
    }
}
