//
//  QuickLoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI

struct QuickLoginView: View {
    
    @Binding var toast: Toast?
    @ObservedObject private(set) var viewModel: QuickLoginViewModel
    private let width: CGFloat
    private let onSuccess: ((AuthData) -> Void)?
    private let onFailure: ((AuthError) -> Void)?
    
    init(_ toast: Binding<Toast?>,
         width: CGFloat,
         viewModel: QuickLoginViewModel = QuickLoginViewModel(
            appleServices: AppleSignInControllerAuthAdapter(
                controller: AppleSignInController())),
         onSuccess: ((AuthData) -> Void)? = nil,
         onFailure: ((AuthError) -> Void)? = nil) {
        self._toast = toast
        self.width = width
        self.viewModel = viewModel
        self.onSuccess = onSuccess
        self.onFailure = onFailure
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
                IconButton(imageName: .custom("google_logo"), size: CGSize(width: buttonWidth, height: buttonHeight)) {
                    // TODO: - Google Sign in
                    viewModel.getError()
                }
                IconButton(
                    imageName: .system("apple.logo"),
                    size: CGSize(width: buttonWidth, height: buttonHeight),
                    action: viewModel.signInWithApple)
                
                IconButton(imageName: .custom("twitter_x_logo"), size: CGSize(width: buttonWidth, height: buttonHeight)) {
                    // TODO: - Twitter Sign in
                    viewModel.getError()
                }
            }
            .padding(.bottom, 30)
        }
        .onReceive(viewModel.$authData) { data in
            guard let data = data else { return }
            
            onSuccess?(data)
        }
        .onReceive(viewModel.$authError) { error in
            guard let error = error else { return }
            
            toast = Toast.showAuthError(error: error)
        }
    }
}

struct QuickLoginView_Previews: PreviewProvider {
    static var previews: some View {
        let toastBinding = Binding<Toast?>(
            get: { return Toast(style: .success, message: "success") },
            set: { _ in }
        )
        QuickLoginView(toastBinding, width: 300)
    }
}
