//
//  QuickSignInViewModelTests.swift
//  TirelessTests
//
//  Created by Liam on 2023/11/30.
//

import XCTest
import Tireless

class QuickSignInViewModelTests: XCTestCase {
    
    func test_signInWithApple_appleFailEmitsFailure() {
        let (sut, authSpy, _) = makeSUT()
        
        sut.signInWithApple()
        authSpy.completeAuthenticate(with: .customError("any error"))
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(sut.authError, .customError("any error"))
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientFailEmitsFailure() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = AuthData(email: "any email", userId: "any user id", name: "any name")
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: anyNSError)
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages.count, 1)
        XCTAssertEqual(sut.authError, .unknown)
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientGetEmptyErrorThenCreateUserFailEmitsFailure() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = AuthData(email: "any email", userId: "any user id", name: "any name")
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: FirestoreError.emptyResult)
        httpSpy.completePost(with: anyNSError)
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages.count, 2)
        XCTAssertEqual(sut.authError, .customError("create error"))
        XCTAssertEqual(sut.authData, nil)
    }
    
    func test_signInWithApple_clientGetEmptyErrorThenCreateUserSuccessfully() {
        let (sut, authSpy, httpSpy) = makeSUT()
        let data = AuthData(email: "any email", userId: "any user id", name: "any name")
        
        sut.signInWithApple()
        authSpy.completeAuthenticateSuccessfully(with: data)
        httpSpy.completeGet(with: FirestoreError.emptyResult)
        httpSpy.completePostSuccessfully()
        
        XCTAssertEqual(authSpy.authenticateCallCount, 1)
        XCTAssertEqual(httpSpy.messages.count, 2)
        XCTAssertEqual(sut.authError, nil)
        XCTAssertEqual(sut.authData, data)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: QuickSignInViewModel, authSpy: AuthControllerSpy, httpSpy: HTTPClientSpy) {
        let authSpy = AuthControllerSpy()
        let httpSpy = HTTPClientSpy()
        let sut = QuickSignInViewModel(appleServices: authSpy, firestore: httpSpy)
        return (sut, authSpy, httpSpy)
    }
}


