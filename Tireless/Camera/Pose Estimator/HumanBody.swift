//
//  HumanBody.swift
//  Tireless
//
//  Created by Liam on 2024/1/30.
//

import Vision

public struct HumanBody {
    
    public enum Group {
        case rightLeg
        case leftLeg
        case rightArm
        case leftArm
        case rootToNose
        
        private var points: [VNHumanBodyPoseObservation.JointName] {
            switch self {
            case .rightLeg:
                return [.rightAnkle, .rightKnee, .rightHip, .root]
            case .leftLeg:
                return [.leftAnkle, .leftKnee, .leftHip, .root]
            case .rightArm:
                return [.rightWrist, .rightElbow, .rightShoulder, .neck]
            case .leftArm:
                return [.leftWrist, .leftElbow, .leftShoulder, .neck]
            case .rootToNose:
                return [.root, .neck, .nose]
            }
        }
        
        func mapper(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> [CGPoint] {
            return self.points.compactMap { points[$0]?.location }
        }
    }
    
    public static func pose(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> [Group: [CGPoint]] {
        let rightLeg = Group.rightLeg.mapper(points)
        let leftLeg = Group.leftLeg.mapper(points)
        let rightArm = Group.rightArm.mapper(points)
        let leftArm = Group.leftArm.mapper(points)
        let rootToNose = Group.rootToNose.mapper(points)
        
        return [.rightLeg: rightLeg, .leftLeg: leftLeg, .rightArm: rightArm, .leftArm: leftArm, .rootToNose: rootToNose]
    }
}
