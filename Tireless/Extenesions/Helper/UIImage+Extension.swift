//
//  UIImage+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/5/1.
//

import UIKit

enum PlanImage: String {
    case squat = "深蹲"
    
    case plank = "棒式"
    
    case pushup = "伏地挺身"
}

extension UIImage {
    static func asset(_ asset: PlanImage) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
    
    static var groupSquat = UIImage(named: "group_squat")
    
    static var groupPlank = UIImage(named: "group_plank")
    
    static var groupPushup = UIImage(named: "group_pushup")
}
