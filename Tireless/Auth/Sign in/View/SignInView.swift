//
//  SignInView.swift
//  Tireless
//
//  Created by Liam on 2023/11/15.
//

import SwiftUI

struct SignInView: View {
    
    @State private var toast: Toast? = nil
    @ObservedObject private(set) var viewModel: SignInViewModel
    @ObservedObject private var quickViewModel = QuickSignInViewModel(
        appleServices: AppleSignInControllerAuthAdapter(
            controller: AppleSignInController()))
        
    var onSuccess: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            LoadingView(isShowing: $viewModel.isLoading) {
                List {
                    HStack {
                        Spacer()
                        makeSignInView(geometry)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .onAppear() {
                    UIScrollView.appearance().bounces = false
                }
                .toastView(toast: $toast)
            }
        }
        .onReceive(viewModel.$authData, perform: mapAuthData)
        .onReceive(viewModel.$authError, perform: mapAuthError)
        .onReceive(quickViewModel.$authData, perform: mapAuthData)
        .onReceive(quickViewModel.$authError, perform: mapAuthError)
        .onReceive(quickViewModel.$isLoading, perform: mapLoading)
        .hideKeyboardOnTap()
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
    private func makeSignInView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width * 0.8
        HStack {
            VStack {
                Image("TirelessLogoText")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .scaledToFill()
                    .colorMultiply(.main)
                
                Text("Login to your Account")
                    .font(.system(.title3))
                    .foregroundColor(.gray)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, 5)
                    .padding(.bottom, 10)
                
                ThemeTextField($viewModel.email, width: width, placeholder: "Email")
                ThemeTextField($viewModel.password, width: width, placeholder: "Password", isSecure: true)
                
                ThemeButton(width: width, name: "Sign in") {
                    viewModel.signIn()
                }
                
                QuickSignInView($toast, width: width, viewModel: quickViewModel)
                
                PolicyView()
                
                noAccountView
                    .padding(.top, 50)
            }
            .padding(.bottom, 20)
        }
        .frame(width: width)
    }
    
    var noAccountView: some View {
        ScrollView {
            HStack {
                Text("Don't have an account?")
                    .font(.system(.body))
                    .foregroundColor(.gray)
                
                NavigationLink(destination: SignupView(viewModel: SignupViewModel(), onSuccess: onSuccess)) {
                    Text("Sign up")
                        .font(.system(.body))
                        .bold()
                        .foregroundColor(.main)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: SignInViewModel()) {}
    }
}

