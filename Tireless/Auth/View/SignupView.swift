//
//  SignupView.swift
//  Tireless
//
//  Created by Liam on 2023/11/16.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    private var viewModel = AuthViewModel()
    
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
                    print("Tap sign up")
                }
                
                QuickLoginView(width: width) {}
            }
            .padding(.bottom, 20)
        }
        .frame(width: width)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
