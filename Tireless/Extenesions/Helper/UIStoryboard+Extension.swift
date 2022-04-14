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
    
    static let shareWall = "ShareWall"
}

extension UIStoryboard {
    
    static var main: UIStoryboard { return tlStoryboard(name: StoryboardCategory.main)}
    
    static var home: UIStoryboard { return tlStoryboard(name: StoryboardCategory.home)}
    
    static var shareWall: UIStoryboard { return tlStoryboard(name: StoryboardCategory.shareWall)}
    
    private static func tlStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: nil)
    }
}
