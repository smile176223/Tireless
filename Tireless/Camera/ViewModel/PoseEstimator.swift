//
//  PoseEstimator.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import AVFoundation
import Vision
import Combine

public class PoseEstimator: ObservableObject {
    
    enum DetectError: Error {
        case lowConfidence
        case sequenceError(Error)
    }
    
    enum HumanBodyGroup {
        case rightLeg
        case leftLeg
        case rightArm
        case leftArm
        case rootToNose
    }
    
    @Published var bodyGroup: [HumanBodyGroup: [CGPoint]]?
    @Published var detectError: DetectError?
    private let sequenceHandler = VNSequenceRequestHandler()
    private var cancellables = Set<AnyCancellable>()
    
    public func captureOutput(_ sampleBuffer: CMSampleBuffer) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectBodyPose)
        
        do {
            try sequenceHandler.perform([humanBodyRequest], on: sampleBuffer, orientation: .up)
        } catch {
            detectError = .sequenceError(error)
        }
    }
    
    private func detectBodyPose(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach(processObservation)
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard var recognizedPoints = try? observation.recognizedPoints(.all) else { return }
        
        recognizedPoints.removeValue(forKey: .leftEar)
        recognizedPoints.removeValue(forKey: .rightEar)
        let pointsConfidence = recognizedPoints.allSatisfy { $0.value.confidence > 0 }
        
        
        if pointsConfidence {
            mapBodyGroup(recognizedPoints)
        } else {
            set(nil)
            set(DetectError.lowConfidence)
        }
    }
    
    private func mapBodyGroup(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        let rightLeg = [points[.rightAnkle]?.location, points[.rightKnee]?.location, points[.rightHip]?.location].compactMap { $0 }
        let leftLeg = [points[.leftAnkle]?.location, points[.leftKnee]?.location, points[.leftHip]?.location].compactMap { $0 }
        let rightArm = [points[.rightWrist]?.location, points[.rightElbow]?.location, points[.rightShoulder]?.location, points[.neck]?.location].compactMap { $0 }
        let leftArm = [points[.leftWrist]?.location, points[.leftElbow]?.location, points[.leftShoulder]?.location, points[.neck]?.location].compactMap { $0 }
        let rootToNose = [points[.root]?.location, points[.neck]?.location, points[.nose]?.location].compactMap { $0 }
        
        let bodyGroup: [HumanBodyGroup: [CGPoint]] = [.rightLeg: rightLeg, .leftLeg: leftLeg, .rightArm: rightArm, .leftArm: leftArm, .rootToNose: rootToNose]
        
        set(bodyGroup)
    }
    
    private func set(_ bodyGroup:  [HumanBodyGroup: [CGPoint]]?) {
        DispatchQueue.main.async {
            self.bodyGroup = bodyGroup
        }
    }
    
    private func set(_ error: DetectError) {
        DispatchQueue.main.async {
            self.detectError = error
        }
    }
}
