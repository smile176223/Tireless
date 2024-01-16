//
//  CameraView.swift
//  Tireless
//
//  Created by Liam on 2024/1/15.
//


import UIKit
import AVFoundation

public final class CameraManager: ObservableObject {
    
    enum Status {
        case configured
        case unConfigured
        case unauthorized
        case failed
    }
    
    @Published var status = Status.unConfigured
    
    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.LiamHsu.Tireless.captureSessionQueue")
    
    public func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.status == .unConfigured else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1280x720
            
            self.setupVideoInput()
            
        }
    }
    
    private func setupVideoInput() {
        do {
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            guard let device = device else {
                status = .unConfigured
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                status = .unConfigured
                session.commitConfiguration()
                return
            }
        } catch {
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func setVideoOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: <#T##dispatch_queue_t?#>)
    }
}
