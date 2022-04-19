//
//  TabBarController.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import UIKit

private enum Tab {

    case home

    case shareWall
    
    case pictureWall

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home:
            controller = UIStoryboard.home.instantiateInitialViewController() ?? UIViewController()
            
        case .shareWall:
            controller = UIStoryboard.shareWall.instantiateInitialViewController() ?? UIViewController()
            
        case .pictureWall:
            controller = UIStoryboard.pictureWall.instantiateInitialViewController() ?? UIViewController()

        }
        
        controller.tabBarItem = tabBarItem()
        
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
        
        return controller
    }
    
    func tabBarItem() -> UITabBarItem {
        
        switch self {

        case .home:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            )

        case .shareWall:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "video.circle"),
                selectedImage: UIImage(systemName: "video.circle.fill")
            )
            
        case .pictureWall:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "personalhotspot.circle"),
                selectedImage: UIImage(systemName: "personalhotspot.circle.fill")
            )
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.home, .shareWall, .pictureWall]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        viewControllers = tabs.map({ $0.controller() })
        
        tabBar.tintColor = .black
        
        tabBar.backgroundColor = .white
        
        tabBar.isTranslucent = false
        
        tabBar.barTintColor = .white
        
        tabBar.unselectedItemTintColor = .gray
        
    }
}
