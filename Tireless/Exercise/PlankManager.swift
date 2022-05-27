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
        let rightElbowShoulder = angle(posePoints[9], posePoints[32], posePoints[30])
        let leftElbowShoulder = angle(posePoints[7], posePoints[30], posePoints[32])
        
        let rightElbowHip = angle(posePoints[9], posePoints[32], posePoints[22])
        let leftElbowHip = angle(posePoints[7], posePoints[30], posePoints[26])
        
        let centerA = (posePoints[22].position.y + posePoints[32].position.y) / 2
        let centerB = (posePoints[26].position.y + posePoints[30].position.y) / 2
        
        if checkAngle(rightElbowShoulder, min: 75, max: 130),
           checkAngle(rightElbowHip, min: 30, max: 85),
           posePoints[28].position.y > centerA * 0.8,
           posePoints[28].position.y > centerB * 0.8,
           posePoints[9].position.y > posePoints[22].position.y {
            isPlank = true
        } else if checkAngle(leftElbowShoulder, min: 75, max: 130),
                  checkAngle(leftElbowHip, min: 30, max: 85),
                  posePoints[28].position.y > centerA * 0.8,
                  posePoints[28].position.y > centerB * 0.8,
                  posePoints[7].position.y > posePoints[26].position.y {
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
