//
//  PlanManageViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/22.
//

import Foundation
import UIKit

class PlanManageViewCell: UICollectionViewCell {
    
    var startButtonTapped: (() -> Void)?
    
    var deleteButtonTapped: (() -> Void)?
    
    @IBOutlet private weak var planImageView: UIImageView!

    @IBOutlet private weak var planTitleLabel: UILabel!
    
    @IBOutlet private weak var planProgressView: UIProgressView!
    
    @IBOutlet private weak var planStartButton: UIButton!

    @IBOutlet private weak var planDeleteButton: UIButton!
    
    @IBOutlet private weak var planTimesLabel: UILabel!
    
    @IBOutlet private weak var planTodayCheckView: UIImageView!
    
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
        if viewModel.plan.planGroup == false {
            planImageView.image = UIImage(named: viewModel.plan.planName)
        } else {
            switch viewModel.plan.planName {
            case PlanExercise.squat.rawValue:
                planImageView.image = UIImage.groupSquat
            case PlanExercise.plank.rawValue:
                planImageView.image = UIImage.groupPlank
            case PlanExercise.pushup.rawValue:
                planImageView.image = UIImage.groupPushup
            default:
                planImageView.image = UIImage.placeHolder
            }
        }
        planTitleLabel.text = viewModel.plan.planName
        planProgressView.progress = Float(viewModel.plan.progress)
        if viewModel.plan.planName == PlanExercise.plank.rawValue {
            planTimesLabel.text = "每天\(viewModel.plan.planTimes)秒，持續\(viewModel.plan.planDays)天"
        } else {
            planTimesLabel.text = "每天\(viewModel.plan.planTimes)次，持續\(viewModel.plan.planDays)天"
        }
        
        let isTodayFinish = viewModel.plan.finishTime.contains(where: { finishTime in
            finishTime.time > getStartOfDay().millisecondsSince1970
        })
        
        if isTodayFinish == true {
            planStartButton.isHidden = true
            planTodayCheckView.isHidden = false
        } else {
            planStartButton.isHidden = false
            planTodayCheckView.isHidden = true
        }
    }
    
    private func getStartOfDay() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let startOfDate = calendar.startOfDay(for: Date())
        return startOfDate
    }
    
    @IBAction func startButtonTap(_ sender: UIButton) {
        startButtonTapped?()
    }
    
    @IBAction func deleteButtonTap(_ sender: UIButton) {
        deleteButtonTapped?()
    }
    
    private func setupLayout() {
        self.layer.cornerRadius = 25
        planImageView.layer.cornerRadius = planImageView.frame.height / 2
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 1
        planStartButton.layer.cornerRadius = self.planStartButton.frame.height / 2
        planStartButton.layer.shadowColor = UIColor.darkGray.cgColor
        planStartButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        planStartButton.layer.shadowOpacity = 1.0
        planStartButton.layer.shadowRadius = 2.0
        planStartButton.layer.masksToBounds = false
    }
}
