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
        let leftBelly = triangleBelly(squatBelly, posePoint[30].position, posePoint[4].position)
        let checkArray = [0, 9, 22, 26, 32]
        if checkInFrameLikelihood(posePoint, checkArray) == true,
           posePoint[0].position.xPoint > 0,
           posePoint[2].position.xPoint < 1.0,
           posePoint[10].position.xPoint < 1.0 {
            if rightBelly > 0.8, rightBelly < 1.2, posePoint[0].position.xPoint < 0.35 ||
                leftBelly > 0.8, leftBelly < 1.2, posePoint[0].position.xPoint < 0.35 {
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
            } else if (posePoint[22].position.xPoint + posePoint[26].position.xPoint) >=
                        ((posePoint[3].position.xPoint + posePoint[4].position.xPoint) * 0.9),
                      checkPointA == true,
                      checkPointB == false,
                      posePoint[0].position.xPoint > 0.35,
                      posePoint[22].position.xPoint > 0.65,
                      posePoint[26].position.xPoint > 0.65 {
                if checkCount == 1 {
                    checkCount += 1
                    checkPointB = true
                }
            }
        }
        return squatCount
    }
    
    private func belly(_ fromPoint: Position, _ toPoint: Position, _ endPoint: Position) -> Position {
        return Position(xPoint: (fromPoint.xPoint + toPoint.xPoint + toPoint.xPoint) / 3,
                        yPoint: (fromPoint.yPoint + toPoint.yPoint + toPoint.yPoint) / 3)
    }
    
    private func triangleBelly(_ fromPoint: Position, _ toPoint: Position, _ endPoint: Position) -> CGFloat {
        let distanceA = CGFloat(hypotf(Float(fromPoint.xPoint - endPoint.xPoint),
                                       Float(fromPoint.yPoint - endPoint.yPoint)))
        let distanceB = CGFloat(hypotf(Float(fromPoint.xPoint - toPoint.xPoint),
                                       Float(fromPoint.yPoint - toPoint.yPoint)))
        let distanceC = CGFloat(hypotf(Float(toPoint.xPoint - endPoint.xPoint),
                                       Float(toPoint.yPoint - endPoint.yPoint)))
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
        return point.position.xPoint > base
    }
}
