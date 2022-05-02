//
//  TabBarController.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import UIKit
import FirebaseAuth

private enum Tab {

    case home
    
    case plan

    case shareWall
    
    case pictureWall
    
    case profile

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home:
            controller = UIStoryboard.home.instantiateInitialViewController() ?? UIViewController()
            
        case .plan:
            controller = UIStoryboard.plan.instantiateInitialViewController() ?? UIViewController()
            
        case .shareWall:
            controller = UIStoryboard.shareWall.instantiateInitialViewController() ?? UIViewController()
            
        case .pictureWall:
            controller = UIStoryboard.pictureWall.instantiateInitialViewController() ?? UIViewController()
            
        case .profile:
            controller = UIStoryboard.profile.instantiateInitialViewController() ?? UIViewController()

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
                image: UIImage.tabHome,
                selectedImage: UIImage.tabHome
            )
            
        case .plan:
            return UITabBarItem(
                title: nil,
                image: UIImage.tabPlan,
                selectedImage: UIImage.tabPlan
            )

        case .shareWall:
            return UITabBarItem(
                title: nil,
                image: UIImage.tabVideo,
                selectedImage: UIImage.tabVideo
            )
            
        case .pictureWall:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "magnifyingglass"),
                selectedImage: UIImage(systemName: "magnifyingglass")
            )
            
        case .profile:
            return UITabBarItem(
                title: nil,
                image: UIImage.tabUser,
                selectedImage: UIImage.tabUser
            )
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.home, .plan, .shareWall, .profile]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        viewControllers = tabs.map({ $0.controller() })
        
        tabBar.tintColor = .themeYellow
        
        tabBar.backgroundColor = .themeBGSecond
        
        tabBar.isTranslucent = false
        
        tabBar.barTintColor = .themeBGSecond
        
        tabBar.unselectedItemTintColor = .white
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard let navVC = viewController as? UINavigationController,
              navVC.viewControllers.first is ProfileViewController else {
            return true
        }

        guard Auth.auth().currentUser != nil else {

            if let authVC = UIStoryboard.auth.instantiateInitialViewController() {

                present(authVC, animated: true, completion: nil)
            }
            
            return false
        }
        
        return true
    }
}
