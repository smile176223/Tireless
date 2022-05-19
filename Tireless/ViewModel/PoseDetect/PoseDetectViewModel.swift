//
//  PoseDetectViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import MLKit
import AVFoundation
import UIKit

class PoseDetectViewModel {
    
    private enum Detector: String {
        case pose = "Pose Detection"
    }
    
    private enum Exercise {
        case squat
        case pushup
        case plank
    }
    
    struct PoseOverlay {
        let poses: [Pose]
        let width: CGFloat
        let height: CGFloat
        let previewLayer: AVCaptureVideoPreviewLayer
    }
    
    var plan: Plan
    
    var videoURL: URL?

    init(plan: Plan) {
        self.plan = plan
        self.setupExercise(with: plan)
    }
    
    let poseViewModels = Box([Pose]())
    
    let confidenceRefresh = Box(String())
    
    let countRefresh = Box(Int(-1))
    
    let isPoseDetectStart = Box(Bool())
    
    let finishExercise = Box(false)
    
    let noPoint = Box(Void())
    
    let updateViewFrame: Box<CMSampleBuffer?> = Box(nil)
    
    let poseViewOverlay: Box<PoseOverlay?> = Box(nil)
    
    private var isUsingFrontCamera = false
    
    private var isPlank = false
    
    private var timer = Timer()
    
    private var plankCountTime = 0
    
    private var poseDetector: PoseDetector?
    
    private let detectors: Detector = .pose
    
    private var currentDetector: Detector = .pose
    
    private var lastDetector: Detector?
    
    private var currentExercise: Exercise = .squat
    
    private let videoRecordManager = VideoRecordManager()
    
    private let videoCapture = VideoCapture()
    
    var recordStatus: RecordStatus = .userAgree
    
    private func detectPose(in sampleBuffer: CMSampleBuffer,
                            width: CGFloat,
                            height: CGFloat,
                            previewLayer: AVCaptureVideoPreviewLayer) {
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(fromDevicePosition: isUsingFrontCamera ? .front : .back)
        visionImage.orientation = orientation
        let activeDetector = self.currentDetector
        resetManagedLifecycleDetectors(activeDetector: activeDetector)
        var posePoint = [PosePoint]()
        if let poseDetector = self.poseDetector {
            var poses: [Pose]
            do {
                poses = try poseDetector.results(in: visionImage)
            } catch {
                return
            }
            guard !poses.isEmpty else {
                self.noPoint.value = ()
                return
            }
            DispatchQueue.main.sync { [weak self] in
                self?.poseViewModels.value = poses
                poses[0].landmarks.forEach {
                    var normalizedPoint = CGPoint(x: $0.position.x / width,
                                                  y: $0.position.y / height)
                    normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
                    posePoint.append(PosePoint(position: CGPoint(x: normalizedPoint.x / UIScreen.main.bounds.width,
                                                                 y: normalizedPoint.y / UIScreen.main.bounds.height),
                                                       zPoint: $0.position.z,
                                                       inFrameLikelihood: $0.inFrameLikelihood,
                                                       type: $0.type.rawValue))
                }
                self?.confidenceRefresh.value = getConfidenceAverage(with: posePoint)
                startExercise(with: posePoint)
            }
        }
    }
    
    func poseDetect(with sampleBuffer: CMSampleBuffer, show previewLayer: AVCaptureVideoPreviewLayer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let target = Int(plan.planTimes) else {
            return
        }
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        if countRefresh.value < target {
            detectPose(in: sampleBuffer,
                       width: imageWidth,
                       height: imageHeight,
                       previewLayer: previewLayer)
        } else if countRefresh.value == target, finishExercise.value == false {
            finishExercise.value = true
        }
    }
    
    private func resetManagedLifecycleDetectors(activeDetector: Detector) {
        if activeDetector == self.lastDetector {
            return
        }
        switch self.lastDetector {
        case .pose:
            self.poseDetector = nil
        default:
            break
        }
        switch activeDetector {
        case .pose:
            let options = activeDetector == .pose ? PoseDetectorOptions() : nil
            self.poseDetector = PoseDetector.poseDetector(options: options ?? PoseDetectorOptions())
        }
        self.lastDetector = activeDetector
    }
    
    private func resetExercise() {
        SquatManager.shared.resetCount()
        PushupManager.shared.resetCount()
        plankCountTime = 0
    }
    
    private func setupExercise(with plan: Plan) {
        resetExercise() 
        switch plan.planName {
        case PlanExercise.squat.rawValue:
            currentExercise = .squat
        case PlanExercise.pushup.rawValue:
            currentExercise = .pushup
        case PlanExercise.plank.rawValue:
            currentExercise = .plank
            setupTimer()
        default:
            currentExercise = .squat
        }
    }
    
    private func startExercise(with posePoint: [PosePoint]) {
        if StartManager.shared.checkStart(posePoint) == true {
            switch currentExercise {
            case .squat:
                countRefresh.value = SquatManager.shared.squatWork(posePoint)
            case .pushup:
                countRefresh.value = PushupManager.shared.pushupWork(posePoint)
            case .plank:
                isPlank = PlankManager.shared.plankWork(posePoint)
                countRefresh.value = plankCountTime
            }
            if self.isPoseDetectStart.value == false {
                self.isPoseDetectStart.value = true
            }
        } else {
            SquatManager.shared.resetIfOut()
            PushupManager.shared.resetIfOut()
        }
    }
    
    private func getConfidenceAverage(with posePoints: [PosePoint]) -> String {
        var average: Float = 0
        for posePoint in posePoints {
            average += posePoint.inFrameLikelihood
        }
        let averagePercent = average / Float(posePoints.count) * 100
        let averageFormat = String(format: "%.0f", averagePercent)
        return averageFormat
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updatePlankTime),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updatePlankTime() {
        if isPlank == true {
            plankCountTime += 1
        }
    }
    
    func stopTimer() {
        timer.invalidate()
    }
}

extension PoseDetectViewModel {
    func startRecording(completion: @escaping (() -> Void)) {
        videoRecordManager.startRecording {
            completion()
        }
    }
    
    func stopRecording(completion: @escaping (() -> Void)) {
        videoRecordManager.stopRecording { url in
            self.videoURL = url
            completion()
        } failure: {
            self.videoURL = nil
            completion()
        }
    }
    
    func userTapBack() {
        videoRecordManager.userTapBack()
    }
    
    func isUserRejectRecord() {
        videoRecordManager.userRejectRecord = { [weak self] in
            self?.recordStatus = .userReject
        }
    }
}

extension PoseDetectViewModel: VideoCaptureDelegate {
    func setupSession() {
        videoCapture.delegate = self
        videoCapture.setupCaptureSession()
    }
    
    func startCapture() {
        videoCapture.startSession()
    }
    
    func stopCapture() {
        videoCapture.stopSession()
    }
    
    func setupPreviewLayer(view: UIView) {
        videoCapture.previewLayer?.frame = view.bounds
    }
    
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer) {
        guard let previewLayer = videoCapture.previewLayer else {
            return
        }
        poseDetect(with: didCaptureVideoFrame, show: previewLayer)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(didCaptureVideoFrame) else {
            return
        }
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))

        DispatchQueue.main.sync { [weak self] in
            guard let self = self else {
                return
            }
            self.updateViewFrame.value = didCaptureVideoFrame
        }
        self.poseViewOverlay.value = PoseOverlay(poses: poseViewModels.value,
                                                 width: imageWidth,
                                                 height: imageHeight,
                                                 previewLayer: previewLayer)
    }

}
