//
//  PoseDetectViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/8.
//

import UIKit
import MLKit
import ReplayKit
import Lottie

class PoseDetectViewController: UIViewController {
    @IBOutlet weak var cameraPreView: UIView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    private enum Constant {
        static let videoDataOutputQueueLabel = "com.LiamHao.Tireless.VideoDataOutputQueue"
        static let sessionQueueLabel = "com.LiamHao.Tireless.SessionQueue"
        static let smallDotRadius: CGFloat = 4.0
        static let lineWidth: CGFloat = 3.0
    }
    
    private var isUsingFrontCamera = false
    
    private var isUserRejectRecording = false
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private lazy var captureSession = AVCaptureSession()
    
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    
    private var lastFrame: CMSampleBuffer?
    
    private let viewModel = PoseDetectViewModel()
    
    private var counter = 0 {
        didSet {
            if counter == 5 {
                self.lottieDetectDone()
            }
        }
    }
    
    private var startFlag = false {
        didSet {
            if startFlag == true {
                lottieCountDownGo()
            }
        }
    }
    
    private var drawStart = false
    
    private var lottieView: AnimationView?
    
    private let videoRecord = VideoRecord()
    
    private var videoUrl: URL?
    
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
        setupBackButton()
    
        recordButton.layer.cornerRadius = 25
        
        tabBarController?.tabBar.isHidden = true
        
        videoRecord.getVideoRecordUrl = { [weak self] url in
            self?.videoUrl = url
        }
        
        videoRecord.userRejectRecord = {
            self.isUserRejectRecording = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoRecord.startRecording {
            self.startSession()
            self.drawStart = true
        }
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
        counter = 5
    }
    
    func blurEffect() {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = cameraPreView.bounds
        cameraPreView.addSubview(effectView)
    }
    
    private func setupBackButton() {
        self.navigationItem.hidesBackButton = true
        let customBackButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                               style: UIBarButtonItem.Style.plain,
                                               target: self,
                                               action: #selector(backTap))
        customBackButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = customBackButton
    }
    
    @objc func backTap(_ sender: UIButton) {
        videoRecord.userTapBack()
        self.navigationController?.popToRootViewController(animated: true)
    }
                                               
    func lottieCountDownGo() {
        countLabel.isHidden = true
        lottieView = .init(name: "CountDownGo")
        lottieView?.frame = view.bounds
        cameraPreView.addSubview(lottieView ?? UIView())
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .playOnce
        lottieView?.animationSpeed = 1.5
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else { return }
            self.lottieView?.removeFromSuperview()
            self.countLabel.isHidden = false
            self.countLabel.text = "\(0)"
            self.drawStart = true
        })
    }
    
    func lottieDetectDone() {
        countLabel.isHidden = true
        drawStart = false
        lottieView = .init(name: "DetectDone")
        lottieView?.frame = view.bounds
        cameraPreView.addSubview(lottieView ?? UIView())
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .playOnce
        lottieView?.animationSpeed = 1
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else { return }
            self.lottieView?.removeFromSuperview()
            self.videoRecord.stopRecording { url in
                self.popupFinish(url)
            } failure: {
                self.popupFinish(self.videoUrl)
            }
        })
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
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
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
    
    func popupFinish(_ videoUrl: URL? = nil) {
        guard let showAlert = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(DetectFinishViewController.self)")
                as? DetectFinishViewController
        else {
            return
        }
        showAlert.videoUrl = videoUrl
        if isUserRejectRecording == true {
            showAlert.isUserRejectRecording = true
        }
        let navShowVC = UINavigationController(rootViewController: showAlert)
        navShowVC.modalPresentationStyle = .overCurrentContext
        navShowVC.modalTransitionStyle = .crossDissolve
        navShowVC.view.backgroundColor = .clear
        
        self.present(navShowVC, animated: true, completion: {
            self.blurEffect()
            self.stopSession()
        })
    }
}

extension PoseDetectViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        lastFrame = sampleBuffer
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
        if counter != 5 {
            viewModel.detectPose(in: sampleBuffer, width: imageWidth, height: imageHeight, previewLayer: previewLayer)
            
            if drawStart == true {
                viewModel.countRefresh = { [weak self] countNumber in
                    if self?.startFlag == false {
                        self?.startFlag = true
                    }
                    self?.countLabel.text = "\(countNumber)"
                    self?.counter = countNumber
                }
                // draw pose
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

extension PoseDetectViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true) {
            self.popupFinish()
        }
    }
}
