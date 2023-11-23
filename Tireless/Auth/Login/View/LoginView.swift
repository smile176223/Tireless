//
//  LoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/15.
//

import SwiftUI

struct LoginView: View {
    
    @State private var toast: Toast? = nil
    @State private var email = ""
    @State private var password = ""
    @ObservedObject private(set) var viewModel: LoginViewModel
    var dismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            List {
                HStack {
                    Spacer()
                    makeLoginView(geometry)
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
        .onReceive(viewModel.$authData) { data in
            guard data != nil else { return }
            
            dismiss()
        }
        .onReceive(viewModel.$authError) { error in
            guard let error = error else { return }
            
            toast = Toast.showAuthError(error: error)
        }
        .hideKeyboardOnTap()
    }
    
    @ViewBuilder
    private func makeLoginView(_ geometry: GeometryProxy) -> some View {
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
                
                ThemeTextField($email, width: width, placeholder: "Email")
                ThemeTextField($password, width: width, placeholder: "Password", isSecure: true)
                
                ThemeButton(width: width, name: "Sign in") {
                    viewModel.signInWithFirebase(email: email, password: password)
                }
                
                QuickLoginView($toast ,width: width, onSuccess: { _ in
                    dismiss()
                })
                
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
                
                NavigationLink(destination: SignupView(viewModel: SignupViewModel(), onSuccess: dismiss)) {
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

struct PolicyView: View {
    @State private var policyIsPresenting = false
    @State private var termsIsPresenting = false
    
    var body: some View {
        Text("By continuing you accept our")
            .font(.system(.caption))
            .foregroundColor(.secondary)
        
        HStack {
            Button(action: {
                self.policyIsPresenting.toggle()
            }) {
                Text("Privacy Policy")
                    .font(.system(.caption).bold())
                    .foregroundColor(.main)
            }
            .buttonStyle(GrowingButton())
            .sheet(isPresented: $policyIsPresenting) {
                WebView(url: URL(string: "https://pages.flycricket.io/tireless-1/privacy.html"))
            }
            
            Text("and")
                .font(.system(.caption))
                .foregroundColor(.secondary)
            
            Button(action: {
                self.termsIsPresenting.toggle()
            }) {
                Text("Terms of Use")
                    .font(.system(.caption).bold())
                    .foregroundColor(.main)
            }
            .buttonStyle(GrowingButton())
            .sheet(isPresented: $termsIsPresenting) {
                WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"))
            }
        }
    }
}

struct IconButton: View {
    enum ImageName {
        case custom(String)
        case system(String)
    }
    
    private let action: () -> Void
    private let imageName: ImageName
    private let size: CGSize

    init(imageName: ImageName, size: CGSize, action: @escaping () -> Void) {
        self.imageName = imageName
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            ZStack {
                Color.white
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(8)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
                
                switch imageName {
                case let .custom(name):
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                    
                case let .system(name):
                    Image(systemName: name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                
            }
        }
        .buttonStyle(GrowingButton())
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel()) {}
    }
}
