//
//  LoadingView.swift
//  Tireless
//
//  Created by Liam on 2024/1/5.
//

import SwiftUI

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
