//
//  PoseDetectViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/8.
//

import UIKit
import MLKit
import AVFoundation
import Lottie

class PoseDetectViewController: UIViewController {
    @IBOutlet weak var cameraPreView: UIView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var inFrameLikeLiHoodLabel: UILabel!
    
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
    
    private let planViewModel = PlanManageViewModel()
    
    var planTarget: Int = 0
    
    var plan: Plan?
    
    private var counter = 0 {
        didSet {
            if counter == planTarget {
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
    
    private let videoRecordManager = VideoRecordManager()
    
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
        
        setupCurrentExercise()
    
        recordButton.layer.cornerRadius = 25
        
        videoRecordManager.getVideoRecordUrl = { [weak self] url in
            self?.videoUrl = url
        }
        
        videoRecordManager.userRejectRecord = { [weak self] in
            self?.isUserRejectRecording = true
        }
        
        viewModel.noPoint = { [weak self] in
            DispatchQueue.main.async {
                self?.inFrameLikeLiHoodLabel.text = "0%"
            }
        }
        
        viewModel.inFrameLikeLiHoodRefresh = { [weak self] inFrameLikeLiHood in
            self?.inFrameLikeLiHoodLabel.text = "\(inFrameLikeLiHood)%"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if plan?.planName == PlanExercise.plank.rawValue {
//            AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
//        }
        videoRecordManager.startRecording { [weak self] in
            self?.startSession()
            self?.drawStart = true
        }
//        startSession()
//        drawStart = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if plan?.planName == PlanExercise.plank.rawValue {
//            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
//        }
        viewModel.stopTimer()
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreView.bounds
    }
    
    @IBAction func recordTap(_ sender: UIButton) {
        counter += 1
    }
    
    private func setupCurrentExercise() {
        guard let plan = plan else {
            return
        }
        viewModel.setupExercise(with: plan)
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
        videoRecordManager.userTapBack()
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func bacKButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
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
            self.videoRecordManager.stopRecording { url in
                self.popupFinish(url)
            } failure: {
                self.popupFinish(self.videoUrl)
            }
        })
    }
    
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
                print("Failed to add capture session output.")
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
                print("Failed to get capture device for camera position: \(cameraPosition)")
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
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
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
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
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
    
    func popupFinish(_ videoURL: URL? = nil) {
        guard let showAlert = UIStoryboard.home.instantiateViewController(
            withIdentifier: "\(DetectFinishViewController.self)")
                as? DetectFinishViewController
        else {
            return
        }
        showAlert.videoURL = videoURL
        showAlert.plan = plan
        if isUserRejectRecording == true {
            showAlert.isUserRejectRecording = true
        }
        let navShowVC = UINavigationController(rootViewController: showAlert)
        navShowVC.modalPresentationStyle = .overCurrentContext
        navShowVC.modalTransitionStyle = .crossDissolve
        navShowVC.view.backgroundColor = .clear
        
        self.present(navShowVC, animated: true, completion: { [weak self] in
            self?.blurEffect()
            self?.stopSession()
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
        DispatchQueue.main.sync {
            self.updatePreviewOverlayViewWithLastFrame()
            self.removeDetectionAnnotations()
        }
        guard let previewLayer = previewLayer else { return }
        if counter != planTarget {
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
                        poses.forEach { poses in
                            let poseOverlayView = UIUtilities.createPoseOverlayView(
                                forPose: poses,
                                inViewWithBounds: self.annotationOverlayView.bounds,
                                lineWidth: Constant.lineWidth,
                                dotRadius: Constant.smallDotRadius,
                                positionTransformationClosure: { (position) -> CGPoint in
                                    return self.normalizedPoint(
                                        fromVisionPoint: position, width: imageWidth, height: imageHeight)
                                }
                            )
                            self.annotationOverlayView.addSubview(poseOverlayView)
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
