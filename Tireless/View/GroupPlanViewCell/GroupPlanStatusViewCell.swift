//
//  GroupPlanStatusViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/2.
//

import UIKit

class GroupPlanStatusViewCell: UITableViewCell {
    
    @IBOutlet weak var groupPlanImageView: UIImageView!
    
    @IBOutlet weak var groupPlanNameLabel: UILabel!
    
    @IBOutlet weak var groupPlanProgressLabel: UILabel!
    
    @IBOutlet weak var groupPlanProgressView: UIProgressView!
    
    var viewModel: PlanViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: PlanViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        guard let viewModel = viewModel else {
            return
        }
        groupPlanNameLabel.text = viewModel.plan.user?.name
        if viewModel.plan.user?.picture == "" {
            groupPlanImageView.image = UIImage.placeHolder
            groupPlanImageView.backgroundColor = .themeBGSecond
        } else {
            groupPlanImageView.loadImage(viewModel.plan.user?.picture)
        }
        groupPlanProgressView.progress = Float(viewModel.plan.progress)
        
        let number = NSNumber(value: viewModel.plan.progress)
        let percent = NumberFormatter.localizedString(from: number, number: .percent)
        groupPlanProgressLabel.text = percent
        
    }
    
    private func setupLayout() {
        groupPlanImageView.image = UIImage.placeHolder
        groupPlanImageView.layer.cornerRadius = groupPlanImageView.frame.height / 2
    }
}
