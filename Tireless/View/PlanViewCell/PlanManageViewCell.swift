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
    
    var isDeleteButtonTap: (() -> Void)?
    
    var isSettingButtonTap: (() -> Void)?
    
    @IBOutlet weak var planImageView: UIImageView!

    @IBOutlet weak var planTitleLabel: UILabel!
    
    @IBOutlet weak var planProgressView: UIProgressView!
    
    @IBOutlet weak var planStartButton: UIButton!

    @IBOutlet weak var planDeleteButton: UIButton!
    
    @IBOutlet weak var planTimesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    @IBAction func startButtonTap(_ sender: UIButton) {
        isStartButtonTap?()
    }
    
    @IBAction func deleteButtonTap(_ sender: UIButton) {
        isDeleteButtonTap?()
    }
    
    @IBAction func settingButtonTap(_ sender: UIButton) {
        isSettingButtonTap?()
    }
    private func setupLayout() {
        self.layer.cornerRadius = 20
        planImageView.layer.cornerRadius = planImageView.frame.height / 2
    }
    
}
