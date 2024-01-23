//
//  SquatEstimator.swift
//  Tireless
//
//  Created by Liam on 2024/1/22.
//

import Foundation
import Vision

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
            !checkPointB,
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
