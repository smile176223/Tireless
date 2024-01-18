//
//  CameraViewModel.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import CoreImage
import Combine

public class CameraViewModel: ObservableObject {
    @Published var error: Error?
    @Published var frame: CGImage?
    @Published var bodyGroup: [PoseEstimator.HumanBodyGroup: [CGPoint]]?
    
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
                guard let image = CGImage.create(from: buffer) else { return nil }
                
                let ciImage = CIImage(cgImage: image)
                
                return self.context.createCGImage(ciImage, from: ciImage.extent)
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
