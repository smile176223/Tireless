//
//  PoseDetectViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/8.
//

import UIKit
import AVFoundation
import MLKit

class PoseDetectViewController: UIViewController {
    @IBOutlet weak var cameraPreView: UIView!
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    let viewModel = PoseDetectViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreView.bounds
    }
    private lazy var previewOverlayView: UIImageView = {
        precondition(isViewLoaded)
        let previewOverlayView = UIImageView(frame: .zero)
        previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
        previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return previewOverlayView
    }()
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    private func setUpCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.beginConfiguration()
            strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
            guard strongSelf.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            strongSelf.captureSession.addOutput(output)
            strongSelf.captureSession.commitConfiguration()
        }
    }
    private func setUpCaptureSessionInput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
            guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                strongSelf.captureSession.beginConfiguration()
                let currentInputs = strongSelf.captureSession.inputs
                for input in currentInputs {
                    strongSelf.captureSession.removeInput(input)
                }
                let input = try AVCaptureDeviceInput(device: device)
                guard strongSelf.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                strongSelf.captureSession.addInput(input)
                strongSelf.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    private func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.startRunning()
        }
    }
    private func stopSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.stopRunning()
        }
    }
    private func setUpPreviewOverlayView() {
        cameraPreView.addSubview(previewOverlayView)
        NSLayoutConstraint.activate([
            previewOverlayView.centerXAnchor.constraint(equalTo: cameraPreView.centerXAnchor),
            previewOverlayView.centerYAnchor.constraint(equalTo: cameraPreView.centerYAnchor),
            previewOverlayView.leadingAnchor.constraint(equalTo: cameraPreView.leadingAnchor),
            previewOverlayView.trailingAnchor.constraint(equalTo: cameraPreView.trailingAnchor),
            previewOverlayView.topAnchor.constraint(equalTo: cameraPreView.topAnchor),
            previewOverlayView.bottomAnchor.constraint(equalTo: cameraPreView.bottomAnchor)
        ])
    }
    private func setUpAnnotationOverlayView() {
        cameraPreView.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
            annotationOverlayView.topAnchor.constraint(equalTo: cameraPreView.topAnchor),
            annotationOverlayView.leadingAnchor.constraint(equalTo: cameraPreView.leadingAnchor),
            annotationOverlayView.trailingAnchor.constraint(equalTo: cameraPreView.trailingAnchor),
            annotationOverlayView.bottomAnchor.constraint(equalTo: cameraPreView.bottomAnchor)
        ])
    }
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }
    private func updatePreviewOverlayViewWithLastFrame() {
        guard let lastFrame = lastFrame, let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
        else {
            return
        }
        self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
    }
    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
        guard let imageBuffer = imageBuffer else {
            return
        }
        let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
        previewOverlayView.image = image
    }
    private func removeDetectionAnnotations() {
        for annotationView in annotationOverlayView.subviews {
            annotationView.removeFromSuperview()
        }
    }
    private func normalizedPoint(
        fromVisionPoint point: VisionPoint,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
        normalizedPoint = previewLayer?.layerPointConverted(fromCaptureDevicePoint: normalizedPoint) ?? CGPoint()
        return normalizedPoint
    }
}

extension PoseDetectViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: isUsingFrontCamera ? .front : .back
        )
        visionImage.orientation = orientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        weak var weakSelf = self
        DispatchQueue.main.sync {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.updatePreviewOverlayViewWithLastFrame()
            strongSelf.removeDetectionAnnotations()
        }
        viewModel.detectPose(in: visionImage, width: imageWidth, height: imageHeight)
        viewModel.poseViewModels.bind { poses in
            DispatchQueue.main.async {
                guard let strongSelf = weakSelf else {
                    print("Self is nil!")
                    return
                }
                poses.forEach { poses in
                    let poseOverlayView = UIUtilities.createPoseOverlayView(
                        forPose: poses,
                        inViewWithBounds: strongSelf.annotationOverlayView.bounds,
                        lineWidth: Constant.lineWidth,
                        dotRadius: Constant.smallDotRadius,
                        positionTransformationClosure: { (position) -> CGPoint in
                            return strongSelf.normalizedPoint(
                                fromVisionPoint: position, width: imageWidth, height: imageHeight)
                        }
                    )
                    strongSelf.annotationOverlayView.addSubview(poseOverlayView)
                }
            }
        }
    }
}

public enum Detector: String {
    case pose = "Pose Detection"
}
private enum Constant {
    static let videoDataOutputQueueLabel = "com.LiamHao.Tireless.VideoDataOutputQueue"
    static let sessionQueueLabel = "com.LiamHao.Tireless.SessionQueue"
    static let smallDotRadius: CGFloat = 4.0
    static let lineWidth: CGFloat = 3.0
}
