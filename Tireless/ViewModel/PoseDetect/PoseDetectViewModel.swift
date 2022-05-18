//
//  PoseDetectViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import Foundation
import MLKit
import AVFoundation

class PoseDetectViewModel {
    
    private enum Detector: String {
        case pose = "Pose Detection"
    }
    
    private enum Exercise {
        case squat
        case pushup
        case plank
    }
    
    let poseViewModels = Box([Pose]())
    
    private var isUsingFrontCamera = false
    
    private var isPlank = false
    
    private var timer = Timer()
    
    private var plankCountTime = 0
    
    private var poseDetector: PoseDetector?
    
    private let detectors: Detector = .pose
    
    private var currentDetector: Detector = .pose
    
    private var lastDetector: Detector?
    
    private var currentExercise: Exercise = .squat
    
    var countRefresh: ((Int) -> Void)?
    
    var inFrameLikeLiHoodRefresh: ((String) -> Void)?
    
    var noPoint: (() -> Void)?
    
    func detectPose(in sampleBuffer: CMSampleBuffer,
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
                self.noPoint?()
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
                self?.inFrameLikeLiHoodRefresh?(getInFrameLikeLiHoodAverage(with: posePoint))
                startExercise(with: posePoint)
            }
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
    
    func resetExercise() {
        SquatManager.shared.resetCount()
        PushupManager.shared.resetCount()
        plankCountTime = 0
    }
    
    func setupExercise(with plan: Plan) {
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
                countRefresh?(SquatManager.shared.squatWork(posePoint))
            case .pushup:
                countRefresh?(PushupManager.shared.pushupWork(posePoint))
            case .plank:
                isPlank = PlankManager.shared.plankWork(posePoint)
                countRefresh?(plankCountTime)
            }
        } else {
            SquatManager.shared.resetIfOut()
            PushupManager.shared.resetIfOut()
        }
    }
    
    func getInFrameLikeLiHoodAverage(with posePoints: [PosePoint]) -> String {
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
