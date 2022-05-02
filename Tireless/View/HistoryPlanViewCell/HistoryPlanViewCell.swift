//
//  HistoryPlanViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/2.
//

import UIKit

class HistoryPlanViewCell: UICollectionViewCell {
    
    @IBOutlet weak var historyImageView: UIImageView!
    
    @IBOutlet weak var historyPlanNameLabel: UILabel!
    
    @IBOutlet weak var historyPlanTimesLabel: UILabel!
    
    @IBOutlet weak var historyFinishTimeLabel: UILabel!
    
    var viewModel: HistoryPlanViewModels?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: HistoryPlanViewModels) {
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
            case PlanImage.squat.rawValue:
                historyImageView.image = UIImage.groupSquat
            case PlanImage.plank.rawValue:
                historyImageView.image = UIImage.groupPlank
            case PlanImage.pushup.rawValue:
                historyImageView.image = UIImage.groupPushup
            default:
                historyImageView.image = UIImage.placeHolder
            }
        }
        historyPlanTimesLabel.text = "每次\(viewModel.plan.planTimes)次/秒，持續\(viewModel.plan.planDays)天"
        historyPlanNameLabel.text = viewModel.plan.planName
        let finish = viewModel.plan.finishTime.endIndex - 1
        let finishDate = Date(milliseconds: viewModel.plan.finishTime[finish]?.time ?? 0)
        historyFinishTimeLabel.text = Date.dateFormatter.string(from: finishDate)
    }
    
    private func setupLayout() {
        self.layer.cornerRadius = 25
        historyImageView.layer.cornerRadius = historyImageView.frame.height / 2
    }
}
