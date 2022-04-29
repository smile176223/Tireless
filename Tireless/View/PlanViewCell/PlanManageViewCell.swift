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
    
    @IBOutlet weak var planSettingButton: UIButton!
    
    @IBOutlet weak var planTimesLabel: UILabel!
    
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
        planImageView.image = UIImage(named: viewModel.plan.planName)
        planTitleLabel.text = viewModel.plan.planName
        planProgressView.progress = Float(viewModel.plan.progress)
        planTimesLabel.text = "\(viewModel.plan.planTimes)次/\(viewModel.plan.planDays)天"
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
