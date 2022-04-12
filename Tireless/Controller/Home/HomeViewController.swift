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
        
        setupTitle()
        
    }
    
    @IBAction func goToNext(_ sender: UIButton) {
        guard let poseVC = storyboard?.instantiateViewController(
            withIdentifier: "\(PoseDetectViewController.self)")
                as? PoseDetectViewController
        else {
            return
        }
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(poseVC, animated: true)
    }
    
    func setupTitle() {
        let titleView = UIImageView()
        titleView.image = UIImage(named: "TirelessLogo")
        titleView.contentMode = .scaleAspectFill
        titleView.clipsToBounds = true
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        titleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120).isActive = true
    }
}
