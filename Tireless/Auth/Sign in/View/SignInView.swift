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
        
    var dismiss: () -> Void
    
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
        
        dismiss()
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

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: SignInViewModel()) {}
    }
}

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width / 5
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    ActivityIndicatorView(isVisible: $isShowing)
                        .frame(width: size, height: size)
                        .foregroundColor(.gray)
                    
                }
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }
}

struct RotatingDotsIndicatorView: View {

    let count: Int

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<count, id: \.self) { index in
                RotatingDotsIndicatorItemView(index: index, size: geometry.size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct RotatingDotsIndicatorItemView: View {

    let index: Int
    let size: CGSize

    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        let animation = Animation
            .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
            .repeatForever(autoreverses: false)

        return Circle()
            .frame(width: size.width / 5, height: size.height / 5)
            .scaleEffect(scale)
            .offset(y: size.width / 10 - size.height / 2)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                rotation = 0
                scale = (5 - CGFloat(index)) / 5
                withAnimation(animation) {
                    rotation = 360
                    scale = (1 + CGFloat(index)) / 5
                }
            }
    }
}

public struct ActivityIndicatorView: View {

    @Binding var isVisible: Bool

    public init(isVisible: Binding<Bool>) {
        _isVisible = isVisible
    }

    public var body: some View {
        if isVisible {
            indicator
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Private
    
    private var indicator: some View {
        ZStack {
            RotatingDotsIndicatorView(count: 5)
        }
    }
}
