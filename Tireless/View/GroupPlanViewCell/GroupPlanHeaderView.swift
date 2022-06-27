//
//  GroupPlanHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/5/3.
//

import UIKit

class GroupPlanHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var planTitleLabel: UILabel!
    
    @IBOutlet private weak var planTimesLabel: UILabel!
    
    @IBOutlet private weak var planCreatedUserLabel: UILabel!
    
    @IBOutlet private weak var planCreatedUserIamgeView: UIImageView!
    
    @IBOutlet private weak var planCreatedNameLabel: UILabel!
    
    @IBOutlet private weak var planJoinUserLabel: UILabel!
    
    private var viewModel: JoinGroup?
    
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
    
    private func layoutHeader() {
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
