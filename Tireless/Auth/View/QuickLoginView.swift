//
//  QuickLoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI
import AuthenticationServices

final class QuickLoginViewModel: NSObject, ObservableObject {
    @Published var loginResult: Result<Void, Error>?
    private var nonce: String?
    private let firebaseAuth: FirebaseAuth
    
    init(nonce: String? = nil, firebaseAuth: FirebaseAuth = FirebaseAuthManager()) {
        self.nonce = nonce
        self.firebaseAuth = firebaseAuth
    }
}

extension QuickLoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIdToken = appleIdCredential.identityToken,
                  let token = String(data: appleIdToken, encoding: .utf8),
                  let currentNonce = nonce else {
                return
            }
            
            firebaseAuth.signInWithApple(idToken: token, nonce: currentNonce) { result in
                switch result {
                case .success:
                    self.loginResult = .success(())
                    
                case let .failure(error):
                    self.loginResult = .failure(error)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginResult = .failure(error)
    }
    
    func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let randomNonce = CryptoKitHelper.randomNonceString()
        nonce = randomNonce
        request.nonce = CryptoKitHelper.sha256(randomNonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}


struct QuickLoginView: View {
    
    @ObservedObject private(set) var viewModel: QuickLoginViewModel
    private let width: CGFloat
    private let dismiss: () -> Void
    
    init(width: CGFloat, viewModel: QuickLoginViewModel = QuickLoginViewModel(), dismiss: @escaping () -> Void) {
        self.width = width
        self.viewModel = viewModel
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            Text("- Or sign up with -")
                .font(.system(.body))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            HStack(spacing: 15) {
                let buttonWidth = (width - 40) / 3
                let buttonHeight = buttonWidth * 0.6
                IconButton(iconImage: "star.fill", size: CGSize(width: buttonWidth, height: buttonHeight)) {
                    print("tap button 1")
                }
                IconButton(
                    iconImage: "apple.logo",
                    size: CGSize(width: buttonWidth, height: buttonHeight),
                    action: viewModel.performAppleSignIn)
                
                IconButton(iconImage: "star", size: CGSize(width: buttonWidth, height: buttonHeight)) {
                    print("tap button 3")
                }
            }
            .padding(.bottom, 30)
        }
        .onReceive(viewModel.$loginResult) { result in
            if case .success = result {
                dismiss()
            }
        }
    }
}

struct QuickLoginView_Previews: PreviewProvider {
    static var previews: some View {
        QuickLoginView(width: 300) {}
    }
}
