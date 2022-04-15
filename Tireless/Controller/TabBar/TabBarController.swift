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

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home: controller = UIStoryboard.home.instantiateInitialViewController()!
            
        case .shareWall: controller = UIStoryboard.shareWall.instantiateInitialViewController()!

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
                image: UIImage(systemName: "magnifyingglass"),
                selectedImage: UIImage(systemName: "magnifyingglass")
            )
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.home, .shareWall]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        viewControllers = tabs.map({ $0.controller() })
        
        tabBar.tintColor = .black
    
    }
}
