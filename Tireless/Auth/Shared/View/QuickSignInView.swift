//
//  QuickLoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI

struct QuickSignInView: View {
    
    @Binding var toast: Toast?
    @ObservedObject private(set) var viewModel: QuickSignInViewModel
    private let width: CGFloat
    
    init(_ toast: Binding<Toast?>,
         width: CGFloat,
         viewModel: QuickSignInViewModel) {
        self._toast = toast
        self.width = width
        self.viewModel = viewModel
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
        let quickViewModel = QuickSignInViewModel(
            appleServices: AppleSignInControllerAuthAdapter(
                controller: AppleSignInController()))
        QuickSignInView(toastBinding, width: 300, viewModel: quickViewModel)
    }
}
