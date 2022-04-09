//
//  PosePoint.swift
//  Tireless
//
//  Created by Hao on 2022/4/9.
//

import UIKit

struct PosePoint {
    var position: Position
    var zPoint: CGFloat
    var inFrameLikelihood: Float
    var type: String
}

struct Position {
    var xPoint: CGFloat
    var yPoint: CGFloat
}
