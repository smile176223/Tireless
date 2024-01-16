//
//  CameraView.swift
//  Tireless
//
//  Created by Liam on 2024/1/15.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    
    private let label = Text("Video feed")
    
    var body: some View {
        if let image = image {
            GeometryReader { geometry in
                Image(image, scale: 1.0, orientation: .upMirrored, label: label)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .clipped()
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
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
