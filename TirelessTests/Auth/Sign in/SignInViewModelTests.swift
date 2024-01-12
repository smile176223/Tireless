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
    
    func test_singInWithFirebase_signInFailureEmitsError() throws {
        let (sut, authSpy, httpSpy) = makeSUT()
        
        sut.email = anyEmail
        sut.password = anyPassword
        sut.signIn()
        authSpy.completeSignInPublisher(with: anyAuthError)
        
        XCTAssertEqual(authSpy.messages, [.signInPublisher(email: anyEmail, password: anyPassword)])
        XCTAssertNil(sut.authData)
        expect(sut.authError, with: anyAuthError)
        try expectKeychain(.userItem, item: nil)
    }
    
    func test_signInWithFirebase_fetchUserWithEmptyDataEmitsError() throws {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = AuthData(email: anyEmail, userId: anyPassword, name: anyName)
        let userItem = UserItem(id: anyUserId, email: anyEmail, name: anyName, picture: nil)
        
        sut.email = anyEmail
        sut.password = anyPassword
        sut.signIn()
        authSpy.completeSignInPublisher(with: data)
        httpSpy.completeGetSuccessfully(with: Data())
        
        XCTAssertEqual(authSpy.messages, [.signInPublisher(email: anyEmail, password: anyPassword)])
        XCTAssertEqual(sut.authError, .customError("Auth data error"))
        try expectKeychain(.userItem, item: userItem)
    }
    
    func test_signInWithFirebase_fetchUserSuccessfullyEmitsValue() throws {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = AuthData(email: anyEmail, userId: anyUserId, name: anyName)
        let userItem = UserItem(id: anyUserId, email: anyEmail, name: anyName, picture: nil)
        
        sut.email = anyEmail
        sut.password = anyPassword
        sut.signIn()
        authSpy.completeSignInPublisher(with: data)
        httpSpy.completeGetSuccessfully(with: anyUserData)
        
        XCTAssertEqual(authSpy.messages, [.signInPublisher(email: anyEmail, password: anyPassword)])
        XCTAssertNil(sut.authError)
        XCTAssertEqual(sut.authData, data)
        try expectKeychain(.userItem, item: userItem)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SignInViewModel, authSpy: FirebaseAuthManagerSpy, httpSpy: HTTPClientSpy) {
        let authSpy = FirebaseAuthManagerSpy()
        let httpSpy = HTTPClientSpy()
        let sut = SignInViewModel(authServices: authSpy, firestore: httpSpy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(httpSpy, file: file, line: line)
        trackForMemoryLeaks(authSpy, file: file, line: line)
        return (sut, authSpy, httpSpy)
    }
    
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
