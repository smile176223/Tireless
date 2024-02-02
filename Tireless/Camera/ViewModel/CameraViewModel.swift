//
//  CameraViewModel.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import CoreImage
import Combine
import SwiftUI

public class CameraViewModel: ObservableObject {
    
    @Published var error: Error?
    @Published var frame: CIImage?
    @Published var bodyGroup: [HumanBody.Group: [CGPoint]]?
    private let context = CIContext()
    private let frameManager = FrameManager()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupSubscriptions()
    }
    
    public func setupSubscriptions() {
        frameManager.cameraManager.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)
        
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                guard let buffer = buffer else { return nil }
                
                return CIImage(cvPixelBuffer: buffer)
            }
            .assign(to: &$frame)
        
        frameManager.poseEstimator.$detectError
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)
        
        frameManager.poseEstimator.$bodyGroup
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$bodyGroup)
    }
}
