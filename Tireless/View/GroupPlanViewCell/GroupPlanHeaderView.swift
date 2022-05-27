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
    
    var viewModel: JoinGroup?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    private func setupLayout() {
        planCreatedUserIamgeView.layer.cornerRadius = planCreatedUserIamgeView.frame.height / 2
    }
    
    func setup(viewModel: JoinGroup) {
        self.viewModel = viewModel
        layoutHeader()
    }
    
    func layoutHeader() {
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.createdUser?.picture == "" {
            planCreatedUserIamgeView.image = UIImage.placeHolder
        } else {
            planCreatedUserIamgeView.loadImage(viewModel.createdUser?.picture)
        }
        planCreatedNameLabel.text = viewModel.createdUser?.name
        planTimesLabel.text = "\(viewModel.planTimes)次/秒，持續\(viewModel.planDays)天"
        planTitleLabel.text = viewModel.planName
    }
    
}
