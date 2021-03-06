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
    
    @IBOutlet private weak var cameraPreView: PoseDetectView!
    
    @IBOutlet private weak var countLabel: UILabel!
    
    @IBOutlet private weak var confidenceLabel: UILabel!
    
    var viewModel: PoseDetectViewModel?

    private var drawPose = false
    
    private var lottieView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.setupSession()
        
        viewModel?.setupVideoRecord()

        setupLabel(countLabel)
        
        setupLabel(confidenceLabel)
        
        setupBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startRecording { [weak self] in
            self?.viewModel?.startCapture()
            self?.drawPose = true
        }
//        self.viewModel?.startCapture()
//        self.drawPose = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.stopTimer()
        
        self.viewModel?.stopCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel?.setupPreviewLayer(view: cameraPreView)
    }
    
    @IBAction func bacKButtonTap(_ sender: UIButton) {
        viewModel?.userTapBack()
        self.dismiss(animated: true)
    }
    
    private func setupBind() {
        viewModel?.noPoint.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.confidenceLabel.text = "人體準確度：0%"
            }
        }
        
        viewModel?.confidenceRefresh.bind { [weak self] inFrameLikeLiHood in
            self?.confidenceLabel.text = "人體準確度：\(inFrameLikeLiHood)%"
        }
        
        viewModel?.countRefresh.bind { [weak self] count in
            if count == -1 {
                self?.countLabel.text = "請盡量拍到全身"
            } else {
                self?.countLabel.text = "\(count)"
            }
        }
        
        viewModel?.isPoseDetectStart.bind { [weak self] isStart in
            if isStart {
                self?.lottieCountDownGo()
            }
        }
        
        viewModel?.finishExercise.bind { [weak self] isFinish in
            if isFinish {
                self?.lottieDetectDone()
            }
        }
        
        viewModel?.updateViewFrame.bind { [weak self] updateViewFrame in
            guard let updateViewFrame = updateViewFrame else {
                return
            }
            self?.cameraPreView.updatePreviewOverlayViewWithLastFrame(
                lastFrame: updateViewFrame.viewFrame,
                isUsingFrontCamera: updateViewFrame.isUsingFrontCamera)
            self?.cameraPreView.removeDetectionAnnotations()
        }
        
        viewModel?.poseViewOverlay.bind { poseOverlay in
            guard let poseOverlay = poseOverlay else {
                return
            }
            if self.drawPose == true {
                self.cameraPreView.drawPoseOverlay(poses: poseOverlay.poses,
                                                   width: poseOverlay.width,
                                                   height: poseOverlay.height,
                                                   previewLayer: poseOverlay.previewLayer)
            }
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
        if let videoURL = viewModel?.videoURL.value {
            finishVC.viewModel = DetectFinishViewModel(plan: plan,
                                                       videoURL: videoURL)
        } else {
            finishVC.viewModel = DetectFinishViewModel(plan: plan,
                                                       videoURL: nil)
        }
        if viewModel?.recordStatus == .userReject {
            finishVC.viewModel?.recordStatus = .userReject
        }
        
        let navFinishVC = UINavigationController(rootViewController: finishVC)
        navFinishVC.modalPresentationStyle = .overCurrentContext
        navFinishVC.modalTransitionStyle = .crossDissolve
        navFinishVC.view.backgroundColor = .clear
        
        self.present(navFinishVC, animated: true, completion: { [weak self] in
            self?.blurEffect()
            self?.viewModel?.stopCapture()
        })
    }
}
