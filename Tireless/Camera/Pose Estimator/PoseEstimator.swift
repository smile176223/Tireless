//
//  PoseEstimator.swift
//  Tireless
//
//  Created by Liam on 2024/1/16.
//

import AVFoundation
import Vision

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
    @Published var count: Int = 0
    private let sequenceHandler = VNSequenceRequestHandler()
    private let squatEstimator = SquatEstimator()
    
    public init() {
        squatEstimator.$count
            .receive(on: RunLoop.main)
            .assign(to: &$count)
    }
    
    public func captureOutput(_ sampleBuffer: CMSampleBuffer) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectBodyPose)
        
        do {
            try sequenceHandler.perform([humanBodyRequest], on: sampleBuffer, orientation: .upMirrored)
        } catch {
            set(error: .sequenceError(error))
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
            squatEstimator.perform(recognizedPoints)
        } else {
            set(nil)
            set(error: DetectError.lowConfidence)
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
    
    private func set(error: DetectError) {
        DispatchQueue.main.async {
            self.detectError = error
        }
    }
}

public class SquatEstimator {
    
    @Published var count = 0
    private var checkPointA = false
    private var checkPointB = false
    private var posture: Posture = .start
    
    enum Posture {
        case start
        case up
        case down
    }
    
    public func perform(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        guard let nose = points.locate(.nose),
              let rightHip = points.locate(.rightHip),
              let leftHip = points.locate(.leftHip),
              let rightKnee = points.locate(.rightKnee),
              let rightShoulder = points.locate(.rightShoulder),
              let leftKnee = points.locate(.leftKnee),
              let leftShoulder = points.locate(.leftShoulder),
              let rightAnkle = points.locate(.rightAnkle),
              let leftAnkle = points.locate(.leftAnkle)
        else {
            return
        }
    
        let squatBelly = belly(nose, rightHip, leftHip)
        let rightBelly = triangleBelly(squatBelly, rightKnee, rightShoulder)
        let leftBelly = triangleBelly(squatBelly, leftKnee, leftShoulder)
        
        let hipY = rightHip.y + leftHip.y
        let kneeY = rightKnee.y + leftKnee.y
        
        if lower(nose, 0.6) || compare(first: hipY, second: kneeY, 1.1) {
            reset()
        }
        
        guard upper(nose) && lower(rightAnkle, 1) && lower(leftAnkle, 1) else {
            return
        }
        
        let initialPose = [
            (between(rightBelly) && lower(nose)) || (between(leftBelly) && lower(nose)),
            posture == .start,
            !checkPointA,
            !checkPointB
        ].allSatisfy { $0 }
        
        let isUpPose = [
            (between(rightBelly) && lower(nose)) || (between(leftBelly) && lower(nose)),
            posture == .down,
            checkPointA,
            checkPointB
        ].allSatisfy { $0 }
        
        let isDownPose = [
            compare(first: hipY, second: kneeY, 0.9),
            checkPointA, 
            checkPointB,
            upper(nose, 0.35),
            upper(rightHip, 0.65),
            upper(leftHip, 0.65),
            posture == .up
        ].allSatisfy { $0 }
        
        
        if initialPose {
            posture = .up
            checkPointA = true
            checkPointB = false
        } else if isUpPose {
            posture = .up
            checkPointA = true
            checkPointB = false
            squatCount()
        } else if isDownPose {
            posture = .down
            checkPointB = true
        }
    }
    
    private func squatCount() {
        DispatchQueue.main.async {
            self.count += 1
        }
    }
    
    private func reset() {
        posture = .start
        checkPointA = false
        checkPointB = false
    }
    
    private func lower(_ point: CGPoint, _ target: CGFloat = 0.35) -> Bool {
        return point.y < target
    }
    
    private func upper(_ point: CGPoint, _ target: CGFloat = 0) -> Bool {
        return point.y > target
    }
    
    private func between(_ target: CGFloat, lower: CGFloat = 0.8, upper: CGFloat = 1.2) -> Bool {
        return (target > lower && target < upper)
    }
    
    private func compare(first: CGFloat, _ firstMultiple: CGFloat = 1.0, second: CGFloat, _ secondMultiple: CGFloat = 1.0) -> Bool {
        return (first * firstMultiple) >= (second * secondMultiple)
    }
    
    private func belly(_ firstPoint: CGPoint, _ secondPoint: CGPoint, _ thirdPoint: CGPoint) -> CGPoint {
        let centerX = (firstPoint.x + secondPoint.x + thirdPoint.x) / 3
        let centerY = (firstPoint.y + secondPoint.y + thirdPoint.y) / 3
        return CGPoint(x: centerX, y: centerY)
    }
    
    private func triangleBelly(_ firstPoint: CGPoint, _ secondPoint: CGPoint, _ thirdPoint: CGPoint) -> CGFloat {
        let distanceA = CGFloat(hypotf(Float(firstPoint.x - thirdPoint.x), Float(firstPoint.y - thirdPoint.y)))
        let distanceB = CGFloat(hypotf(Float(firstPoint.x - secondPoint.x), Float(firstPoint.y - secondPoint.y)))
        let distanceC = CGFloat(hypotf(Float(secondPoint.x - thirdPoint.x), Float(secondPoint.y - thirdPoint.y)))
        return (distanceA + distanceB) / distanceC
    }
}

extension Dictionary where Key == VNHumanBodyPoseObservation.JointName, Value == VNRecognizedPoint {
    func locate(_ jointName: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
        guard let point = self[jointName], point.confidence > 0.5  else { return nil }
        
        return point.location
    }
}
