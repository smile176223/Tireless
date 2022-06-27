//
//  UIStoryboard+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import UIKit

private struct StoryboardCategory {
    static let main = "Main"
    
    static let auth = "Auth"
    
    static let home = "Home"
    
    static let plan = "Plan"
    
    static let groupPlan = "GroupPlan"
    
    static let shareWall = "ShareWall"
    
    static let poseDetect = "PoseDetect"
    
    static let profile = "Profile"
}

extension UIStoryboard {
    
    static var main: UIStoryboard { return tlStoryboard(name: StoryboardCategory.main)}
    
    static var auth: UIStoryboard { return tlStoryboard(name: StoryboardCategory.auth)}
    
    static var home: UIStoryboard { return tlStoryboard(name: StoryboardCategory.home)}
    
    static var plan: UIStoryboard { return tlStoryboard(name: StoryboardCategory.plan)}
    
    static var groupPlan: UIStoryboard { return tlStoryboard(name: StoryboardCategory.groupPlan)}
    
    static var shareWall: UIStoryboard { return tlStoryboard(name: StoryboardCategory.shareWall)}
    
    static var poseDetect: UIStoryboard { return tlStoryboard(name: StoryboardCategory.poseDetect)}
    
    static var profile: UIStoryboard { return tlStoryboard(name: StoryboardCategory.profile)}
    
    private static func tlStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
