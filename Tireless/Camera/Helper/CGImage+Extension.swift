//
//  CGImage+Extension.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import CoreGraphics
import VideoToolbox

extension CGImage {
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else { return nil }
        
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        return image
    }
}