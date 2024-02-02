//
//  CameraView.swift
//  Tireless
//
//  Created by Liam on 2024/1/15.
//

import SwiftUI

struct FrameView: View {
    var image: Image?
    
    var body: some View {
        if let image = image {
            GeometryReader { geometry in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        } else {
            EmptyView()
        }
    }
}

public struct CameraView: View {
    @StateObject private var model = CameraViewModel()
    
    public var body: some View {
        ZStack {
            GeometryReader { geo in
                FrameView(image: model.frame?.image)
                    .edgesIgnoringSafeArea(.all)
                
                StickFigureView(bodyGroup: model.bodyGroup, size: geo.size)
            }
        }
    }
}
