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
    
    @IBOutlet weak var planImageView: UIImageView!

    @IBOutlet weak var planTitleLabel: UILabel!
    
    @IBOutlet weak var planProgressView: UIProgressView!
    
    @IBOutlet weak var planStartButton: UIButton!

    @IBOutlet weak var planDeleteButton: UIButton!
    
    @IBOutlet weak var planTimesLabel: UILabel!
    
    @IBOutlet weak var planTodayCheckView: UIImageView!
    
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
            finishTime?.time ?? 0 > getStartOfDay().millisecondsSince1970
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
        isStartButtonTap?()
    }
    
    @IBAction func deleteButtonTap(_ sender: UIButton) {
        isDeleteButtonTap?()
    }
    
    private func setupLayout() {
        self.layer.cornerRadius = 25
        planImageView.layer.cornerRadius = planImageView.frame.height / 2
    }
}
