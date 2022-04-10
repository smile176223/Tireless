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
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var recordButtonTap: UIButton!
    
    private var isUsingFrontCamera = false
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    let viewModel = PoseDetectViewModel()
    
    var counter = 5
    var startFlag = false {
        didSet {
            countDownTimer()
        }
    }
    
    var isRecording: Bool = false
    var videoWriterH264: VideoWriter!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        setUpPreviewOverlayView()
        setUpAnnotationOverlayView()
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
        
        videoWriterH264 = VideoWriter(withVideoType: AVVideoCodecType.h264)
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
    @IBAction func recordTap(_ sender: Any) {
        if isRecording {
            isRecording = false
            videoWriterH264.stopWriting(completionHandler: { (status) in
                print("Done recording H264")
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: self.videoWriterH264.url.path)
                    let fileSize = attr[FileAttributeKey.size] as? UInt64
                    UISaveVideoAtPathToSavedPhotosAlbum(self.videoWriterH264.url.path, nil, nil, nil)
                    print("H264 file size = \(String(describing: fileSize))")
                    print(status)
                } catch {
                    print("error")
                }
            })
        } else {
            isRecording = true
        }
    }
    private func setUpCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.beginConfiguration()
            strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
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
    
    private func countDownTimer() {
        if startFlag == true {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let strongSelf = self else { return }
                if strongSelf.counter > 1 {
                    strongSelf.counter -= 1
                    strongSelf.countLabel.text = "\(strongSelf.counter)"
                } else if strongSelf.counter == 1 {
                    strongSelf.countLabel.text = "Start"
                    strongSelf.counter = 0
                } else if strongSelf.counter == 0 {
                    strongSelf.counter = -1
                    timer.invalidate()
                }
                
            }
        }
    }
    
    private func downAlert() {
        let showAlert = UIAlertController(title: "Finish!", message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 230))
        imageView.image = UIImage(systemName: "person.circle") // Your image here...
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view ?? UIView(),
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: showAlert.view ?? UIView(),
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "結束!", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(showAlert, animated: true, completion: nil)
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
        guard let previewLayer = previewLayer else { return }
        viewModel.detectPose(in: visionImage, width: imageWidth, height: imageHeight, previewLayer: previewLayer)
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
        viewModel.countRefresh = { [weak self] countNumber in
            if self?.startFlag == false {
                self?.startFlag = true
            }
            if self?.counter == -1 {
                self?.countLabel.text = "\(countNumber)"
            }
            if countNumber == 5 {
                self?.downAlert()
            }
        }
        if isRecording {
            videoWriterH264.write(sampleBuffer: sampleBuffer)
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
