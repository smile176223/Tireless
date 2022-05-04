//
//  SquatManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import Foundation
import MLKit

class SquatManager {
    static let shared = SquatManager()
    
    private var squatCount = 0
    
    private var checkCount = 0
    
    private var checkPointA = false
    
    private var checkPointB = false
    
    func squatWork(_ posePoints: [PosePoint]) -> Int {
        let squatBelly = belly(posePoints[0].position, posePoints[22].position, posePoints[26].position)
        let rightBelly = triangleBelly(squatBelly, posePoints[3].position, posePoints[32].position)
        let leftBelly = triangleBelly(squatBelly, posePoints[4].position, posePoints[30].position)
        let checkArray = [0, 9, 22, 26, 32]
        if posePoints[3].position.y < 0.6 ||
            ((posePoints[22].position.y + posePoints[26].position.y) >
             ((posePoints[3].position.y + posePoints[4].position.y)) * 1.1) {
            resetIfOut()
        }
        if checkInFrameLikelihood(posePoints, checkArray) == true,
           posePoints[0].position.y > 0,
           posePoints[2].position.y < 1.0,
           posePoints[10].position.y < 1.0 {
            if rightBelly > 0.8 && rightBelly < 1.2 && posePoints[0].position.y < 0.35 ||
                leftBelly > 0.8 && leftBelly < 1.2 && posePoints[0].position.y < 0.35 {
                if checkCount == 0, checkPointA == false, checkPointB == false {
                    checkCount += 1
                    checkPointA = true
                    checkPointB = false
                } else if checkCount == 2, checkPointA == true, checkPointB == true {
                    checkCount = 1
                    squatCount += 1
                    checkPointA = true
                    checkPointB = false
                }
            } else if (posePoints[22].position.y + posePoints[26].position.y) >=
                        ((posePoints[3].position.y + posePoints[4].position.y) * 0.9),
                      checkPointA == true,
                      checkPointB == false,
                      posePoints[0].position.y > 0.35,
                      posePoints[22].position.y > 0.65,
                      posePoints[26].position.y > 0.65 {
                if checkCount == 1 {
                    checkCount += 1
                    checkPointB = true
                }
            }
        }
        return squatCount
    }
    
    func resetIfOut() {
        checkCount = 0
        checkPointA = false
        checkPointB = false
    }
    
    private func belly(_ fromPoint: CGPoint, _ toPoint: CGPoint, _ endPoint: CGPoint) -> CGPoint {
        return CGPoint(x: (fromPoint.x + toPoint.x + toPoint.x) / 3,
                       y: (fromPoint.y + toPoint.y + toPoint.y) / 3)
    }
    
    private func triangleBelly(_ fromPoint: CGPoint, _ toPoint: CGPoint, _ endPoint: CGPoint) -> CGFloat {
        let distanceA = CGFloat(hypotf(Float(fromPoint.x - endPoint.x),
                                       Float(fromPoint.y - endPoint.y)))
        let distanceB = CGFloat(hypotf(Float(fromPoint.x - toPoint.x),
                                       Float(fromPoint.y - toPoint.y)))
        let distanceC = CGFloat(hypotf(Float(toPoint.x - endPoint.x),
                                       Float(toPoint.y - endPoint.y)))
        return (distanceA + distanceB) / distanceC
    }
    
    private func checkInFrameLikelihood(_ poses: [PosePoint], _ checkNumber: [Int]) -> Bool {
        for index in checkNumber {
            if poses[index].inFrameLikelihood > 0.5 {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    private func checkBaseline(_ point: PosePoint, _ base: CGFloat) -> Bool {
        return point.position.x > base
    }
}
