//
//  UIStoryboard+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import UIKit

private struct StoryboardCategory {
    static let main = "Main"
    
    static let home = "Home"
    
    static let plan = "Plan"
    
    static let shareWall = "ShareWall"
    
    static let pictureWall = "PictureWall"
    
    static let profile = "Profile"
}

extension UIStoryboard {
    
    static var main: UIStoryboard { return tlStoryboard(name: StoryboardCategory.main)}
    
    static var home: UIStoryboard { return tlStoryboard(name: StoryboardCategory.home)}
    
    static var plan: UIStoryboard { return tlStoryboard(name: StoryboardCategory.plan)}
    
    static var shareWall: UIStoryboard { return tlStoryboard(name: StoryboardCategory.shareWall)}
    
    static var pictureWall: UIStoryboard { return tlStoryboard(name: StoryboardCategory.pictureWall)}
    
    static var profile: UIStoryboard { return tlStoryboard(name: StoryboardCategory.profile)}
    
    private static func tlStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: nil)
    }
}
