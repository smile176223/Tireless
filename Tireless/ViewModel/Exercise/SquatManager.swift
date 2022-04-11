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
    
    func squatWork(_ posePoint: [PosePoint]) -> Int {
        let squatBelly = belly(posePoint[0].position, posePoint[22].position, posePoint[26].position)
        let rightBelly = triangleBelly(squatBelly, posePoint[3].position, posePoint[32].position)
        let leftBelly = triangleBelly(squatBelly, posePoint[4].position, posePoint[30].position)
        let checkArray = [0, 9, 22, 26, 32]
        if posePoint[3].position.y < 0.6 ||
            ((posePoint[22].position.y + posePoint[26].position.y) >
             ((posePoint[3].position.y + posePoint[4].position.y)) * 1.1) {
            resetIfOut()
        }
        if checkInFrameLikelihood(posePoint, checkArray) == true,
           posePoint[0].position.y > 0,
           posePoint[2].position.y < 1.0,
           posePoint[10].position.y < 1.0 {
            if rightBelly > 0.8 && rightBelly < 1.2 && posePoint[0].position.y < 0.35 ||
                leftBelly > 0.8 && leftBelly < 1.2 && posePoint[0].position.y < 0.35 {
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
            } else if (posePoint[22].position.y + posePoint[26].position.y) >=
                        ((posePoint[3].position.y + posePoint[4].position.y) * 0.9),
                      checkPointA == true,
                      checkPointB == false,
                      posePoint[0].position.y > 0.35,
                      posePoint[22].position.y > 0.65,
                      posePoint[26].position.y > 0.65 {
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
