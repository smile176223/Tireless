//
//  PlanManageViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation
import UIKit

class PlanManageViewCell: UICollectionViewCell {
    
    var isStartButtonTap: (() -> Void)?
    
    @IBOutlet weak var planImageView: UIImageView!

    @IBOutlet weak var planTitleLabel: UILabel!
    
    @IBOutlet weak var planProgressView: UIProgressView!
    
    @IBOutlet weak var planStartButton: UIButton!

    @IBAction func startButtonTap(_ sender: UIButton) {
        isStartButtonTap?()
    }
}
