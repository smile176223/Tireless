//
//  TabBarController.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import UIKit
import FirebaseAuth
import SwiftUI

private enum Tab {
    case home
    case plan
    case profile

    func controller() -> UIViewController {
        var controller: UIViewController
        switch self {
        case .home:
            controller = UIStoryboard.home.instantiateInitialViewController() ?? UIViewController()
        case .plan:
            controller = UIStoryboard.plan.instantiateInitialViewController() ?? UIViewController()
        case .profile:
            controller = UIStoryboard.profile.instantiateInitialViewController() ?? UIViewController()
        }
        controller.tabBarItem = tabBarItem()
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 2.0, right: 0.0)
        return controller
    }
    
    func tabBarItem() -> UITabBarItem {
        switch self {
        case .home:
            return UITabBarItem(
                title: "主頁",
                image: UIImage.tabHome,
                selectedImage: UIImage.tabHome
            )
        case .plan:
            return UITabBarItem(
                title: "計畫",
                image: UIImage.tabPlan,
                selectedImage: UIImage.tabPlan
            )
        case .profile:
            return UITabBarItem(
                title: "個人",
                image: UIImage.tabUser,
                selectedImage: UIImage.tabUser
            )
        }
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.home, .plan, .profile]
    
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
            let signInView = NavigationView {
                SignInView(viewModel: SignInViewModel()) {
                    self.presentedViewController?.dismiss(animated: true)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            
            let hostingVC = UIHostingController(rootView: signInView)
            hostingVC.modalPresentationStyle = .fullScreen
            
            present(hostingVC, animated: true)
            return false
        }
        return true
    }
}
