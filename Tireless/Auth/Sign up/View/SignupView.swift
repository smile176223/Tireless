//
//  SignupView.swift
//  Tireless
//
//  Created by Liam on 2023/11/16.
//

import SwiftUI

struct SignupView: View {
    
    @State private var toast: Toast? = nil
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @ObservedObject private(set) var viewModel: SignupViewModel
    var onSuccess: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            List {
                HStack {
                    Spacer()
                    makeSignupView(geometry)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .onAppear() {
                UIScrollView.appearance().bounces = false
            }
        }
        .toastView(toast: $toast)
        .onReceive(viewModel.$authData) { data in
            guard data != nil else { return }
            
            onSuccess()
        }
        .onReceive(viewModel.$authError) { error in
            guard let error = error else { return }
            
            toast = Toast.showAuthError(error: error)
        }
    }
    
    @ViewBuilder
    private func makeSignupView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width * 0.8
        HStack {
            VStack {
                Image("TirelessLogoText")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .scaledToFill()
                    .colorMultiply(.main)
            
                Text("Create your Account")
                    .font(.system(.title3))
                    .foregroundColor(.gray)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 5)
                    .padding(.bottom, 10)
                
                ThemeTextField($email, width: width, placeholder: "Email")
                ThemeTextField($password, width: width, placeholder: "Password", isSecure: true)
                ThemeTextField($confirmPassword, width: width, placeholder: "Confirm Password", isSecure: true)
                
                ThemeButton(width: width, name: "Sign up") {
                    viewModel.signUpWithFirebase(email: email, password: password, confirmPassword: confirmPassword)
                }
                
                QuickSignInView($toast, width: width)
            }
            .padding(.bottom, 20)
        }
        .frame(width: width)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(viewModel: SignupViewModel()) {}
    }
}
