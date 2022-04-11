//
//  StartManager.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import Foundation

class StartManager {
    static let shared = StartManager()
    
    func checkStart(_ posePoint: [PosePoint]) -> Bool {
        if posePoint.allSatisfy({ $0.inFrameLikelihood > 0.5 }) &&
            posePoint[3].position.y < 1.0 &&
            posePoint[4].position.y < 1.0 &&
            posePoint[0].position.y < 0.3 {
            return true
        }
        return false
    }
}
