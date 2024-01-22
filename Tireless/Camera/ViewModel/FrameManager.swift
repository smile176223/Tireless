//
//  FrameManager.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import AVFoundation

public class FrameManager: NSObject, ObservableObject {

    @Published var current: CVPixelBuffer?
    public let cameraManager = CameraManager()
    public let poseEstimator = PoseEstimator()
    private let videoOutputQueue = DispatchQueue(label: "com.LiamHsu.tireless.videoOutputQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    public override init() {
        super.init()
        cameraManager.set(self, queue: videoOutputQueue)
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
                self.current = buffer
            }
            
            poseEstimator.captureOutput(sampleBuffer)
        }
    }
}
