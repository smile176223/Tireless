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
        return posePoint.allSatisfy { $0.inFrameLikelihood > 0.5 }
    }
}
