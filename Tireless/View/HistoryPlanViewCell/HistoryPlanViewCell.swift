//
//  HistoryPlanViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/2.
//

import UIKit

class HistoryPlanViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var historyImageView: UIImageView!
    
    @IBOutlet private weak var historyPlanNameLabel: UILabel!
    
    @IBOutlet private weak var historyPlanTimesLabel: UILabel!
    
    @IBOutlet private weak var historyFinishTimeLabel: UILabel!
    
    private var viewModel: HistoryPlanViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: HistoryPlanViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.plan.planGroup == false {
            historyImageView.image = UIImage(named: viewModel.plan.planName)
        } else {
            switch viewModel.plan.planName {
            case PlanExercise.squat.rawValue:
                historyImageView.image = UIImage.groupSquat
            case PlanExercise.plank.rawValue:
                historyImageView.image = UIImage.groupPlank
            case PlanExercise.pushup.rawValue:
                historyImageView.image = UIImage.groupPushup
            default:
                historyImageView.image = UIImage.placeHolder
            }
        }
        historyPlanTimesLabel.text = "每次\(viewModel.plan.planTimes)次/秒，持續\(viewModel.plan.planDays)天"
        if viewModel.plan.planGroup == true {
            historyPlanNameLabel.text = "\(viewModel.plan.planName) (團體)"
        } else {
            historyPlanNameLabel.text = "\(viewModel.plan.planName) (個人)"
        }
        let finish = viewModel.plan.finishTime.endIndex - 1
        let finishDate = Date(milliseconds: viewModel.plan.finishTime[finish].time)
        historyFinishTimeLabel.text = "完成時間: \(Date.dateFormatter.string(from: finishDate))"
    }
    
    private func setupLayout() {
        self.layer.cornerRadius = 25
        historyImageView.layer.cornerRadius = historyImageView.frame.height / 2
    }
}
