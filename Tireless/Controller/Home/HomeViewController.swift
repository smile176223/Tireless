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
        let title = UILabel()
        title.text = "Tireless"
        title.textColor = .black
        title.textAlignment = .center
        title.font = title.font.withSize(80)
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
    }
}
