//
//  QuickSignInViewModelTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/30.
//

import XCTest
import Tireless

class QuickSignInViewModelTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        undoSideEffect()
    }
    
    func test_signInWithApple_appleFailEmitsFailure() {
        let (sut, authSpy, _) = makeSUT()
        
        sut.signInWithApple()
        authSpy.completeAuthenticate(with: anyAuthError)
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(sut.authError, anyAuthError)
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientFailEmitsFailure() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = anyAuthData
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: anyNSError)
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages, [.get(endpoint: .user(id: anyUserId))])
        XCTAssertEqual(sut.authError, .unknown)
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientGetEmptyErrorThenCreateUserFailEmitsFailure() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = anyAuthData
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: FirestoreError.emptyResult)
        httpSpy.completePost(with: anyNSError)
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages, [.get(endpoint: .user(id: anyUserId)), .post(endpoint: .user(id: anyUserId), param: data.dict)])
        XCTAssertEqual(sut.authError, .customError("create error"))
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientGetEmptyErrorThenCreateUserSuccessfully() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = anyAuthData
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: FirestoreError.emptyResult)
        httpSpy.completePostSuccessfully()
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages, [.get(endpoint: .user(id: anyUserId)), .post(endpoint: .user(id: anyUserId), param: data.dict)])
        XCTAssertEqual(sut.authError, nil)
        XCTAssertEqual(sut.authData, data)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: QuickSignInViewModel, authSpy: AuthControllerSpy, httpSpy: HTTPClientSpy) {
        let authSpy = AuthControllerSpy()
        let httpSpy = HTTPClientSpy()
        let sut = QuickSignInViewModel(appleServices: authSpy, firestore: httpSpy)
        trackForMemoryLeaks(authSpy, file: file, line: line)
        trackForMemoryLeaks(httpSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, authSpy, httpSpy)
    }
    
    private var anyAuthData: AuthData {
        AuthData(email: anyEmail, userId: anyUserId, name: anyName)
    }
    
    private func undoSideEffect() {
        try? KeychainManager.delete(.userItem)
    }
}


