//
//  ThemeButton.swift
//  Tireless
//
//  Created by Liam on 2023/11/17.
//

import SwiftUI

struct ThemeButton: View {
    
    let width: CGFloat
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(name)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .frame(minWidth: width,  minHeight: 44)
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
}


struct ThemeButton_Previews: PreviewProvider {
    static var previews: some View {
        ThemeButton(width: 300, name: "Theme") {}
    }
}
