//
//  SignupView.swift
//  Tireless
//
//  Created by Liam on 2023/11/16.
//

import SwiftUI

struct SignupView: View {
    
    @State private var toast: Toast? = nil
    @ObservedObject private(set) var viewModel: SignupViewModel
    @ObservedObject private var quickViewModel = QuickSignInViewModel(
        appleServices: AppleSignInControllerAuthAdapter(
            controller: AppleSignInController()))
    
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
        .onReceive(viewModel.$authData, perform: mapAuthData)
        .onReceive(viewModel.$authError, perform: mapAuthError)
        .onReceive(quickViewModel.$authData, perform: mapAuthData)
        .onReceive(quickViewModel.$authError, perform: mapAuthError)
        .onReceive(quickViewModel.$isLoading, perform: mapLoading)
    }
    
    private func mapAuthData(_ data: AuthData?) {
        guard data != nil else { return }
        
        onSuccess()
    }
    
    private func mapAuthError(_ error: AuthError?) {
        guard let error = error else { return }
        
        Toast.showError(&toast, error: error)
    }
    
    private func mapLoading(_ isLoading: Bool) {
        viewModel.isLoading = isLoading
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
                
                ThemeTextField($viewModel.name, width: width, placeholder: "Name")
                ThemeTextField($viewModel.email, width: width, placeholder: "Email")
                ThemeTextField($viewModel.password, width: width, placeholder: "Password", isSecure: true)
                ThemeTextField($viewModel.confirmPassword, width: width, placeholder: "Confirm Password", isSecure: true)
                
                ThemeButton(width: width, name: "Sign up") {
                    viewModel.signUp()
                }
                
                QuickSignInView($toast, width: width, viewModel: quickViewModel)
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
