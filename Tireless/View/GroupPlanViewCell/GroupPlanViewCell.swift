//
//  GroupPlanViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/3.
//

import UIKit

class GroupPlanViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupPlanImageView: UIImageView!
    
    var viewModel: JoinUsersViewModel?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    private func setupLayout() {
        groupPlanImageView.layer.cornerRadius = groupPlanImageView.frame.height / 2
    }
    
    func setup(viewModel: JoinUsersViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        if viewModel?.user.picture != "" {
            groupPlanImageView.loadImage(viewModel?.user.picture)
        } else {
            groupPlanImageView.image = UIImage.placeHolder
        }
    }
}
