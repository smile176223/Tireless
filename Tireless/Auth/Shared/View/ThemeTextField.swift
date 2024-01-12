//
//  ThemeTextField.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI

struct ThemeTextField: View {
    @Binding var text: String
    private let width: CGFloat
    private let placeholder: String
    private let isSecure: Bool
    @FocusState private var focused: Bool
    
    init(_ text: Binding<String>, width: CGFloat, placeholder: String, isSecure: Bool = false) {
        self._text = text
        self.width = width
        self.placeholder = placeholder
        self.isSecure = isSecure
    }
    
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray).bold())
                    .lineLimit(1)
                    .textFieldStyle(TappableTextFieldStyle(edgeInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)))
 
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray).bold())
                    .lineLimit(1)
                    .textFieldStyle(TappableTextFieldStyle(edgeInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)))
            }
        }
        .frame(width: width, height: 50)
        .padding(.bottom, 20)
    }
}


struct TappableTextFieldStyle: TextFieldStyle {
    @FocusState private var textFieldFocused: Bool
    var edgeInsets: EdgeInsets
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(edgeInsets)
            .background(Color.clear)
            .focused($textFieldFocused)
            .onTapGesture {
                textFieldFocused = true
            }
    }
}
