//
//  PushupManager.swift
//  Tireless
//
//  Created by Hao on 2022/5/3.
//

import Foundation
import MLKit

class PushupManager {
    static let shared = PushupManager()
    
    private var pushupCount = 0
    
    private var checkPointA = false
    
    private var checkPointB = false
    
    private var checkPointC = true
    
    private var startPointUp = CGPoint(x: 0, y: 0)
    
    private var startPointDown = CGPoint(x: 0, y: 0)
    
    func resetIfOut() {
        startPointUp = CGPoint(x: 0, y: 0)
        startPointDown = CGPoint(x: 0, y: 0)
        checkPointA = false
        checkPointB = false
        checkPointC = true
    }
    
    func resetCount() {
        pushupCount = 0
    }
    
    func pushupWork(_ posePoints: [PosePoint]) -> Int {
        if checkInFrameLikeHood(posePoints) == false {
            resetIfOut()
        }
        let hipToShoulder = posePoints[22].position.y - posePoints[32].position.y
        let wristToShoulder = posePoints[5].position.y - posePoints[32].position.y
        startPointUp = getPolygonAreaCenter(posePoints)
        if hipToShoulder > 0.10, hipToShoulder < 0.30, wristToShoulder > 0.10,
           startPointUp.y < 0.5, startPointUp.x > 0.1, startPointUp.x < 0.75 { 
            if checkPointA == false, checkPointB == false, checkPointC == true {
                checkPointA = true
                if startPointUp.y < 0.5, startPointUp.y > 0.1, startPointUp.y < 0.75,
                checkPointA == true, checkPointB == false, checkPointC == true {
                    checkPointC = false
                }
            } else if checkPointA == true, checkPointB == true, checkPointC == true {
                checkPointB = false
                pushupCount += 1
                if startPointDown.y > 0.5, startPointDown.x > 0.1, startPointDown.x < 0.75,
                   checkPointA == true, checkPointB == false, checkPointC == true {
                    checkPointC = false
                }
            }
        }
        if checkPointA == true, checkPointB == false, checkPointC == false,
           startPointUp.y > 0.5, startPointUp.x > 0.1, startPointUp.y < 0.75,
           hipToShoulder < 0.15, wristToShoulder < 0.30 {
            checkPointB = true
            if startPointUp.y > 0.5, startPointUp.x > 0.1, startPointUp.x < 0.75,
               checkPointA == true, checkPointB == true, checkPointC == false {
                startPointDown = getPolygonAreaCenter(posePoints)
                checkPointC = true
            }
        }
        return pushupCount
    }
    
    private func getPolygonAreaCenter(_ posePoint: [PosePoint]) -> CGPoint {
        var xPointSum: CGFloat = 0
        var yPointSum: CGFloat = 0
        var areaSum: CGFloat = 0
        var point1 = posePoint[1].position
        var tempPoint = posePoint
        tempPoint.remove(at: 32)
        tempPoint.remove(at: 30)
        tempPoint.remove(at: 22)
        tempPoint.remove(at: 3)
        for index in 0..<tempPoint.count {
            let point2 = tempPoint[index].position
            let area = area(from: tempPoint[0].position, to: point1, end: point2)
            areaSum += area
            xPointSum += (tempPoint[0].position.x + point1.x + point2.x) * area
            yPointSum += (tempPoint[0].position.y + point1.y + point1.y) * area
            point1 = point2
        }
        return CGPoint(x: (xPointSum / areaSum / 3), y: (yPointSum / areaSum / 3))
    }
    
    private func area(from pointA: CGPoint, to pointB: CGPoint, end pointC: CGPoint) -> CGFloat {
        let area = (pointA.x * pointB.y) + (pointB.x * pointC.y) + (pointC.x * pointA.y) -
        (pointB.x * pointA.y) - (pointC.x * pointB.y) - (pointA.x * pointC.y)
        return abs(area) * 0.5
    }
    
    private func checkInFrameLikeHood(_ posePoint: [PosePoint]) -> Bool {
        return posePoint.allSatisfy { posePoint in
            posePoint.inFrameLikelihood > 0.8
        }
    }
}
