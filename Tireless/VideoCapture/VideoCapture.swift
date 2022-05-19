//
//  CameraConfig.swift
//  Tireless
//
//  Created by Hao on 2022/5/18.
//

import AVFoundation
import UIKit

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer)
}

class VideoCapture: NSObject {
    
    // only for test mode
    var isUsingFrontCamera = false
    
    weak var delegate: VideoCaptureDelegate?
    
    private enum Constant {
        static let videoDataOutputQueueLabel = "com.LiamHao.Tireless.VideoDataOutputQueue"
        static let sessionQueueLabel = "com.LiamHao.Tireless.SessionQueue"
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    lazy var captureSession = AVCaptureSession()
    
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    
    private func setUpCaptureSessionOutput() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(self, queue: outputQueue)
            guard self.captureSession.canAddOutput(output) else {
                return
            }
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
        }
    }
    
    private func setUpCaptureSessionInput() {
        sessionQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                return
            }
            do {
                self.captureSession.beginConfiguration()
                let currentInputs = self.captureSession.inputs
                for input in currentInputs {
                    self.captureSession.removeInput(input)
                }
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
            } catch {
                return
            }
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }
    
    func setupCaptureSession() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.setUpCaptureSessionOutput()
        self.setUpCaptureSessionInput()
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        delegate?.videoCapture(self, didCaptureVideoFrame: sampleBuffer)
    }
}
