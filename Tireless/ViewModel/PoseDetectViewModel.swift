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
    let posePointViewModels = Box([PosePointViewModel]())
    let poseViewModels = Box([Pose]())
    private var poseDetector: PoseDetector?
    private let detectors: Detector = .pose
    private var currentDetector: Detector = .pose
    private var lastDetector: Detector?
    private let squatManager = SquatManager()
    private let startManager = StartManager()
    var countRefresh: ((Int) -> Void)?
    
    func detectPose(in image: VisionImage, width: CGFloat, height: CGFloat, previewLayer: AVCaptureVideoPreviewLayer) {
        let activeDetector = self.currentDetector
        resetManagedLifecycleDetectors(activeDetector: activeDetector)
        var posePoint = [PosePoint]()
        if let poseDetector = self.poseDetector {
            var poses: [Pose]
            do {
                poses = try poseDetector.results(in: image)
            } catch let error {
                print("Failed to detect poses with error: \(error.localizedDescription).")
                return
            }
            weak var weakSelf = self
            guard !poses.isEmpty else {
                print("Pose detector returned no results.")
                return
            }
            DispatchQueue.main.sync {
                guard let strongSelf = weakSelf else {
                    print("Self is nil!")
                    return
                }
                strongSelf.poseViewModels.value = poses
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
                
                if startManager.checkStart(posePoint) == true {
                    strongSelf.countRefresh?(strongSelf.squatManager.squatWork(posePoint))
                } else {
                    strongSelf.squatManager.resetIfOut()
                }
            }
        }
    }
    
    func resetManagedLifecycleDetectors(activeDetector: Detector) {
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
    
    func convertPosePointToViewModel(from posePoints: [PosePoint]) -> [PosePointViewModel] {
        var viewModels = [PosePointViewModel]()
        for posePoint in posePoints {
            let viewModel = PosePointViewModel(model: posePoint)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setPosePoint(_ posePoint: [PosePoint]) {
        posePointViewModels.value = convertPosePointToViewModel(from: posePoint)
    }
}

private enum Constant {
    static let smallDotRadius: CGFloat = 4.0
    static let lineWidth: CGFloat = 3.0
}
