//
//  PlanReviewHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/5/5.
//

import UIKit

class PlanReviewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var planImageView: UIImageView!
    
    @IBOutlet weak var planNameLabel: UILabel!
    
    @IBOutlet weak var planTImesLabel: UILabel!
    
    @IBOutlet weak var planProgressBar: UIProgressView!
    
    @IBOutlet weak var planBackgroundView: UIView!
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    private func setupLayout() {
        planImageView.layer.cornerRadius = self.planImageView.frame.height / 2
        planBackgroundView.layer.cornerRadius = 15
    }
}
