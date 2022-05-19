//
//  PoseDetectViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/8.
//

import UIKit
import AVFoundation
import Lottie

class PoseDetectViewController: UIViewController {
    
    @IBOutlet weak var cameraPreView: PoseDetectView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var inFrameLikeLiHoodLabel: UILabel! // Naming
    
    var viewModel: PoseDetectViewModel? //
    
//    private let videoCapture = VideoCapture() //

    private var drawPose = false
    
    private var lottieView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        videoCapture.setupCaptureSession()
        
//        videoCapture.delegate = self
        
        viewModel?.setupSession()

        setupLabel(countLabel)
        
        setupLabel(inFrameLikeLiHoodLabel)
        
        setupBind()
        
        viewModel?.userRejectRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startRecording { [weak self] in
//            self?.videoCapture.startSession()
            self?.viewModel?.startCapture()
            self?.drawPose = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel?.stopTimer()
        
//        videoCapture.stopSession()
        self.viewModel?.stopCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        videoCapture.previewLayer?.frame = cameraPreView.bounds
        viewModel?.setupPreviewLayer(view: cameraPreView)
    }
    
    @IBAction func bacKButtonTap(_ sender: UIButton) {
        viewModel?.userTapBack()
        self.dismiss(animated: true)
    }
    
    private func setupBind() {
        viewModel?.noPoint = { [weak self] in
            DispatchQueue.main.async {
                self?.inFrameLikeLiHoodLabel.text = "人體準確度：0%"
            }
        }
        
        viewModel?.inFrameLikeLiHoodRefresh.bind { [weak self] inFrameLikeLiHood in
            self?.inFrameLikeLiHoodLabel.text = "人體準確度：\(inFrameLikeLiHood)%"
        }
        
        viewModel?.countRefresh.bind { [weak self] count in
            if count == -1 {
                self?.countLabel.text = "請盡量拍到全身"
            } else {
                self?.countLabel.text = "\(count)"
            }
        }
        
        viewModel?.isPoseDetectStart.bind { [weak self] bool in
            if bool == true {
                DispatchQueue.main.async {
                    self?.lottieCountDownGo()
                }
            }
        }
        
        viewModel?.finishExercise.bind { [weak self] bool in
            if bool == true {
                DispatchQueue.main.async {
                    self?.lottieDetectDone()
                }
            }
        }
        
        viewModel?.updateViewFrame.bind { [weak self] viewFrame in
            self?.cameraPreView.updatePreviewOverlayViewWithLastFrame(
                lastFrame: viewFrame,
                isUsingFrontCamera: false)
            self?.cameraPreView.removeDetectionAnnotations()
        }
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
            self.drawPose = true
        })
    }
    private func lottieDetectDone() {
        drawPose = false
        setupLottie(Lottie.detectDone.name, speed: 1)
        lottieView?.play(completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.lottieView?.removeFromSuperview()
            self.viewModel?.stopRecording {
                self.popupFinish()
            }
        })
    }
    
    private func popupFinish() {
        guard let finishVC = UIStoryboard.poseDetect.instantiateViewController(
            withIdentifier: "\(DetectFinishViewController.self)")
                as? DetectFinishViewController
        else {
            return
        }
        guard let plan = viewModel?.plan else {
            return
        }
//        finishVC.videoURL = videoURL
        finishVC.viewModel?.videoURL = viewModel?.videoURL
        // finishVC.plan = plan
        finishVC.viewModel = DetectFinishViewModel(plan: plan)
//        if recordStatus == .userReject {
//            finishVC.recordStatus = .userReject
//        }
        if viewModel?.recordStatus == .userReject {
            finishVC.viewModel?.recordStatus = .userReject
        }
        
        let navFinishVC = UINavigationController(rootViewController: finishVC)
        navFinishVC.modalPresentationStyle = .overCurrentContext
        navFinishVC.modalTransitionStyle = .crossDissolve
        navFinishVC.view.backgroundColor = .clear
        
        self.present(navFinishVC, animated: true, completion: { [weak self] in
            self?.blurEffect()
//            self?.videoCapture.stopSession()
            self?.viewModel?.stopCapture()
        })
    }
}

//extension PoseDetectViewController: VideoCaptureDelegate {
//    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer) {
//        guard let previewLayer = videoCapture.previewLayer else {
//            return
//        }
//        viewModel?.drawPose(with: didCaptureVideoFrame, show: previewLayer)
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(didCaptureVideoFrame) else {
//            return
//        }
//        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
//        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
//
//        DispatchQueue.main.sync { [weak self] in
//            guard let self = self else {
//                return
//            }
//            self.cameraPreView.updatePreviewOverlayViewWithLastFrame(
//                lastFrame: didCaptureVideoFrame,
//                isUsingFrontCamera: self.videoCapture.isUsingFrontCamera)
//            self.cameraPreView.removeDetectionAnnotations()
//        }
//
//        viewModel?.poseViewModels.bind { [weak self] poses in
//            if self?.drawPose == true {
//                self?.cameraPreView.drawPoseOverlay(poses: poses,
//                                                    width: imageWidth,
//                                                    height: imageHeight,
//                                                    previewLayer: previewLayer)
//            }
//        }
//    }
//}
