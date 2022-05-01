//
//  HomeGroupPlanViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/1.
//

import Foundation
import UIKit

class HomeGroupPlanViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var groupTitleLabel: UILabel!

    @IBOutlet weak var groupUserImageView: UIImageView!
    
    @IBOutlet weak var groupUserNameLabel: UILabel!
    
    var viewModel: JoinGroupsViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setupLayout() {
        self.layer.cornerRadius = 15
        groupUserImageView.layer.cornerRadius = 15
    }
    
    func setup(viewModel: JoinGroupsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func layoutCell() {
        groupTitleLabel.text = viewModel?.joinGroup.planName
        groupUserNameLabel.text = viewModel?.joinGroup.createdName
        switch viewModel?.joinGroup.planName {
        case PlanImage.squat.rawValue:
            groupImageView.image = UIImage.groupSquat
        case PlanImage.plank.rawValue:
            groupImageView.image = UIImage.groupPlank
        case PlanImage.pushup.rawValue:
            groupImageView.image = UIImage.groupPushup
        default:
            groupImageView.image = UIImage(named: "TirelessLogo")
            
        }
    }
}
