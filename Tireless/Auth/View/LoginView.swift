//
//  LoginView.swift
//  Tireless
//
//  Created by Liam on 2023/11/15.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    private var viewModel = AuthViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Image("TirelessLogoText")
                        .resizable()
                        .frame(width: 150, height: 150, alignment: .center)
                        .scaledToFill()
                        .colorMultiply(.black)
                    
                    Text("Login to your Account")
                        .font(.system(.title3))
                        .foregroundColor(.gray)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, 5)
                        .padding(.bottom, 10)
                    
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray).bold())
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                        .padding(.bottom, 10)
                    
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray).bold())
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                        .padding(.bottom, 20)
                    
                    Button {
                        print("Tap Sign In")
                    } label: {
                        Text("Sign In")
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .frame(minWidth: geometry.size.width * 0.8, maxWidth: .infinity,  minHeight: 44)
                            .font(Font.body)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.black))
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(GrowingButton())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    .padding(.bottom, 50)
                    
                    Text("- Or sign in with -")
                        .font(.system(.body))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 15) {
                        let buttonWidth = (geometry.size.width - 40) / 3
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
                    
                    Spacer()
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(.body))
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        Button(action: {
                            print("Sign up click")
                        }) {
                            Text("Sign up")
                                .font(.system(.body))
                                .bold()
                                .foregroundColor(.brown)
                                .padding(.bottom, 20)
                        }
                        .buttonStyle(GrowingButton())
                    }
                }
            }
        }
        .padding(.leading, 40)
        .padding(.trailing, 40)
    }
}

struct IconButton: View {
    private let action: () -> Void
    private let iconImage: String
    private let size: CGSize

    init(iconImage: String, size: CGSize, action: @escaping () -> Void) {
        self.iconImage = iconImage
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
                    .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                
                Image(systemName: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(.black)
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
        LoginView()
    }
}
