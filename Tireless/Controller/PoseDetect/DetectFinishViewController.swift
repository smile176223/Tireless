//
//  DetectFinishViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/11.
//

import UIKit

class DetectFinishViewController: UIViewController {
    
    @IBOutlet var detectFinishView: DetectFinishView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    private func setupButton() {
        detectFinishView.downButton.addTarget(self, action: #selector(finishPresent), for: .touchUpInside)
    }
    
    @objc func finishPresent() {
        guard let shareVC = storyboard?.instantiateViewController(withIdentifier: "\(ShareWallViewController.self)")
                as? ShareWallViewController
        else {
            return
        }
        self.navigationController?.pushViewController(shareVC, animated: true)
        
    }
}
