//
//  HomeViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        goButton.layer.cornerRadius = 10
        
    }
    
    @IBAction func goToNext(_ sender: UIButton) {
        guard let poseVC = storyboard?.instantiateViewController(withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(poseVC, animated: true)
    }
}
