//
//  QuickLoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI

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
                IconButton(imageName: .custom("google_logo"), size: CGSize(width: buttonWidth, height: buttonHeight)) {
                    print("tap button 1")
                }
                IconButton(
                    imageName: .system("apple.logo"),
                    size: CGSize(width: buttonWidth, height: buttonHeight),
                    action: viewModel.performAppleSignIn)
                
                IconButton(imageName: .custom("twitter_x_logo"), size: CGSize(width: buttonWidth, height: buttonHeight)) {
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
