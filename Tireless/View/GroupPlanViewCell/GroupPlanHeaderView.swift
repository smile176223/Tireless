//
//  GroupPlanHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/5/3.
//

import UIKit

class GroupPlanHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var planTitleLabel: UILabel!
    
    @IBOutlet weak var planTimesLabel: UILabel!
    
    @IBOutlet weak var planCreatedUserLabel: UILabel!
    
    @IBOutlet weak var planCreatedUserIamgeView: UIImageView!
    
    @IBOutlet weak var planCreatedNameLabel: UILabel!
    
    @IBOutlet weak var planJoinUserLabel: UILabel!
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    private func setupLayout() {
        planCreatedUserIamgeView.layer.cornerRadius = planCreatedUserIamgeView.frame.height / 2
    }
    
}
