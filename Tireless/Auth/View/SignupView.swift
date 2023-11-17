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
    
    private func makeSignupView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width * 0.8
        return HStack {
            VStack {
                Image("TirelessLogoText")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .scaledToFill()
                    .colorMultiply(.brown)
                
                Group {
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
                    
                    Button {
                        print("Tap Sign up")
                    } label: {
                        Text("Sign up")
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .frame(minWidth: width, maxWidth: .infinity,  minHeight: 44)
                            .font(Font.title3.bold())
                            .background(RoundedRectangle(cornerRadius: 12).fill(.brown))
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(GrowingButton())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    .padding(.bottom, 40)
                }
                
                Group {
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
                        IconButton(iconImage: "apple.logo", size: CGSize(width: buttonWidth, height: buttonHeight)) {
                            print("tap button 2")
                        }
                        IconButton(iconImage: "star", size: CGSize(width: buttonWidth, height: buttonHeight)) {
                            print("tap button 3")
                        }
                    }
                    .padding(.bottom, 30)
                }
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
