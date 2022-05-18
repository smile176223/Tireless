//
//  PoseDetectViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/8.
//

import UIKit
import MLKit
import Lottie

class PoseDetectViewController: UIViewController {
    
    @IBOutlet weak var cameraPreView: PoseDetectView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var inFrameLikeLiHoodLabel: UILabel!
    
    private var lastFrame: CMSampleBuffer?
    
    private let viewModel = PoseDetectViewModel()
    
    private let planViewModel = PlanManageViewModel()
    
    private let videoCapture = VideoCapture()
    
    private var recordStatus: RecordStatus = .userAgree
    
    var plan: Plan?
    
    private var counter = 0 {
        didSet {
            guard let plan = plan else {
                return
            }
            if counter == Int(plan.planTimes) {
                self.lottieDetectDone()
            }
        }
    }
    
    private enum Status {
        case start
        case stop
    }
    
    private var poseDetectStatus: Status = .stop {
        didSet {
            if poseDetectStatus == .start {
                lottieCountDownGo()
            }
        }
    }
    
    private var drawPoseDetect: Status = .stop
    
    private var lottieView: AnimationView?
    
    private let videoRecordManager = VideoRecordManager()
    
    private var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCapture.setupCaptureSession()
        
        videoCapture.delegate = self

        setupLabel(countLabel)
        
        setupLabel(inFrameLikeLiHoodLabel)
        
        videoRecordManager.getVideoRecordUrl = { [weak self] url in
            self?.videoUrl = url
        }
        
        videoRecordManager.userRejectRecord = { [weak self] in
            self?.recordStatus = .userReject
        }
        
        viewModel.noPoint = { [weak self] in
            DispatchQueue.main.async {
                self?.inFrameLikeLiHoodLabel.text = "人體準確度：0%"
            }
        }
        
        viewModel.inFrameLikeLiHoodRefresh = { [weak self] inFrameLikeLiHood in
            self?.inFrameLikeLiHoodLabel.text = "人體準確度：\(inFrameLikeLiHood)%"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCurrentExercise()
        
        videoRecordManager.startRecording { [weak self] in
            self?.videoCapture.startSession()
            self?.drawPoseDetect = .start
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.stopTimer()
        
        videoCapture.stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoCapture.previewLayer?.frame = cameraPreView.bounds
    }
    
    @IBAction func bacKButtonTap(_ sender: Any) {
        videoRecordManager.userTapBack()
        self.dismiss(animated: true)
    }
    
    private func setupCurrentExercise() {
        viewModel.resetExercise()
        guard let plan = plan else {
            return
        }
        viewModel.setupExercise(with: plan)
    }
    
    private func setupLabel(_ label: UILabel) {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
    }
    
    private func blurEffect() {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = cameraPreView.bounds
        cameraPreView.addSubview(effectView)
    }
    
    private func setupLottie(_ name: String, speed: Double) {
        countLabel.isHidden = true
        lottieView = .init(name: name)
        lottieView?.frame = view.bounds
        cameraPreView.addSubview(lottieView ?? UIView())
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .playOnce
        lottieView?.animationSpeed = speed
    }
    
    private func lottieCountDownGo() {
        setupLottie(Lottie.countDownGo.name, speed: 1.5)
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.lottieView?.removeFromSuperview()
            self.countLabel.isHidden = false
            self.countLabel.text = "\(0)"
            self.drawPoseDetect = .start
        })
    }
    private func lottieDetectDone() {
        drawPoseDetect = .stop
        setupLottie(Lottie.detectDone.name, speed: 1)
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.lottieView?.removeFromSuperview()
            self.videoRecordManager.stopRecording { url in
                self.popupFinish(url)
            } failure: {
                self.popupFinish(self.videoUrl)
            }
        })
    }
    
    private func popupFinish(_ videoURL: URL? = nil) {
        guard let showAlert = UIStoryboard.poseDetect.instantiateViewController(
            withIdentifier: "\(DetectFinishViewController.self)")
                as? DetectFinishViewController
        else {
            return
        }
        showAlert.videoURL = videoURL
        showAlert.plan = plan
        if recordStatus == .userReject {
            showAlert.recordStatus = .userReject
        }
        let navShowVC = UINavigationController(rootViewController: showAlert)
        navShowVC.modalPresentationStyle = .overCurrentContext
        navShowVC.modalTransitionStyle = .crossDissolve
        navShowVC.view.backgroundColor = .clear
        
        self.present(navShowVC, animated: true, completion: { [weak self] in
            self?.blurEffect()
            self?.videoCapture.stopSession()
        })
    }
}

extension PoseDetectViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(didCaptureVideoFrame) else {
            return
        }
        lastFrame = didCaptureVideoFrame
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.cameraPreView.updatePreviewOverlayViewWithLastFrame(
                lastFrame: self.lastFrame,
                isUsingFrontCamera: self.videoCapture.isUsingFrontCamera)
            self.cameraPreView.removeDetectionAnnotations()
        }
        
        guard let previewLayer = videoCapture.previewLayer,
              let plan = plan else {
            return
        }
        
        if counter != Int(plan.planTimes) {
            viewModel.detectPose(in: didCaptureVideoFrame,
                                 width: imageWidth,
                                 height: imageHeight,
                                 previewLayer: previewLayer)
            if drawPoseDetect == .start {
                viewModel.countRefresh = { [weak self] countNumber in
                    if self?.poseDetectStatus == .stop {
                        self?.poseDetectStatus = .start
                    }
                    self?.countLabel.text = "\(countNumber)"
                    self?.counter = countNumber
                }
                viewModel.poseViewModels.bind { [weak self] poses in
                    self?.cameraPreView.drawPoseOverlay(poses: poses,
                                                        width: imageWidth,
                                                        height: imageHeight,
                                                        previewLayer: previewLayer)
                }
            }
        }
    }
}
