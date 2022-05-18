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
    
    let videoCapture = VideoCapture()
    
    private var isUserRejectRecording = false
    
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
            self?.isUserRejectRecording = true
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
            self?.drawStart = true
        }
        // just for demo
//        videoCapture.startSession()
//        drawStart = true
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
    
    func blurEffect() {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = cameraPreView.bounds
        cameraPreView.addSubview(effectView)
    }
    
    @IBAction func bacKButtonTap(_ sender: Any) {
        videoRecordManager.userTapBack()
        self.dismiss(animated: true)
    }
    
    func setupLottie(_ name: String, speed: Double) {
        countLabel.isHidden = true
        lottieView = .init(name: name)
        lottieView?.frame = view.bounds
        cameraPreView.addSubview(lottieView ?? UIView())
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .playOnce
        lottieView?.animationSpeed = speed
    }
    
    func lottieCountDownGo() {
        setupLottie("CountDownGo", speed: 1.5)
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.lottieView?.removeFromSuperview()
            self.countLabel.isHidden = false
            self.countLabel.text = "\(0)"
            self.drawStart = true
        })
    }
    
    func lottieDetectDone() {
        drawStart = false
        setupLottie("DetectDone", speed: 1)
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
        DispatchQueue.main.async {
            self.cameraPreView.updatePreviewOverlayViewWithLastFrame(
                lastFrame: self.lastFrame,
                isUsingFrontCamera: self.videoCapture.isUsingFrontCamera)
            self.cameraPreView.removeDetectionAnnotations()
        }
        
        guard let previewLayer = videoCapture.previewLayer else { return }
        guard let plan = plan else { return }
        if counter != Int(plan.planTimes) {
            viewModel.detectPose(in: didCaptureVideoFrame,
                                 width: imageWidth,
                                 height: imageHeight,
                                 previewLayer: previewLayer)
            
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
                    self.cameraPreView.drawPoseOverlay(poses: poses,
                                                       width: imageWidth,
                                                       height: imageHeight,
                                                       previewLayer: previewLayer)
                }
            }
        }
    }
}
