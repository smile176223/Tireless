//
//  PlankManager.swift
//  Tireless
//
//  Created by Hao on 2022/5/4.
//

import Foundation
import MLKit

class PlankManager {
    static let shared = PlankManager()
    
    private var isPlank = false
    
    func plankWork(_ posePoints: [PosePoint]) -> Bool {
        let ankelToHipRight = angle(posePoints[22], posePoints[3], posePoints[2])
        let shoulderToKneeRight = angle(posePoints[32], posePoints[22], posePoints[3])
        let shoulderToWristRight = angle(posePoints[32], posePoints[9], posePoints[5])
        let elbowToHipRight = angle(posePoints[7], posePoints[32], posePoints[22])
        
        let ankelToHipLeft = angle(posePoints[26], posePoints[4], posePoints[10])
        let shoulderToKneeLeft = angle(posePoints[30], posePoints[26], posePoints[4])
        let shoulderToWristLeft = angle(posePoints[30], posePoints[7], posePoints[29])
        let elbowToHipLeft = angle(posePoints[9], posePoints[30], posePoints[26])
        
        if checkAngle(ankelToHipRight, min: 160, max: 185),
           checkAngle(shoulderToKneeRight, min: 160, max: 185),
           checkAngle(shoulderToWristRight, min: 73, max: 110),
           checkAngle(elbowToHipRight, min: 60, max: 110),
           comparePosePoint(pointA: posePoints[30], pointB: posePoints[32], min: 0.9, max: 1.1) {
            isPlank = true
        } else if checkAngle(ankelToHipLeft, min: 160, max: 185),
                  checkAngle(shoulderToKneeLeft, min: 160, max: 185),
                  checkAngle(shoulderToWristLeft, min: 73, max: 110),
                  checkAngle(elbowToHipLeft, min: 60, max: 110),
                  comparePosePoint(pointA: posePoints[32], pointB: posePoints[30], min: 0.9, max: 1.1) {
            isPlank = true
        } else {
            isPlank = false
        }
        return isPlank
    }
    
    private func checkAngle(_ angle: CGFloat, min: CGFloat, max: CGFloat) -> Bool {
        if angle < max, angle > min {
            return true
        } else {
            return false
        }
    }
    
    private func comparePosePoint(pointA: PosePoint, pointB: PosePoint, min: Double, max: Double) -> Bool {
        if pointA.position.x > pointB.position.x * min,
           pointA.position.x < pointB.position.x * max,
           pointA.position.y > pointB.position.y * min,
           pointA.position.y < pointB.position.y * max {
            return true
        } else {
            return false
        }
    }
    
    private func angle(_ firstLandmark: PosePoint, _ midLandmark: PosePoint, _ lastLandmark: PosePoint) -> CGFloat {
        let radians: CGFloat =
        atan2(lastLandmark.position.y - midLandmark.position.y,
              lastLandmark.position.x - midLandmark.position.x) -
        atan2(firstLandmark.position.y - midLandmark.position.y,
              firstLandmark.position.x - midLandmark.position.x)
        var degrees = radians * 180.0 / .pi
        degrees = abs(degrees)
        if degrees > 180.0 {
            degrees = 360.0 - degrees
        }
        return degrees
    }
}
