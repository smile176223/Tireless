//
//  StatisticsViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/12.
//

import UIKit

class StatisticsViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var squatCountLabel: UILabel!
    
    @IBOutlet private weak var pushupCountLabel: UILabel!
    
    @IBOutlet private weak var plankCountLabel: UILabel!
    
    @IBOutlet private weak var completeLabel: UILabel!
    
    private var viewModel: Statistics?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
    }
    
    func setup(viewModel: Statistics) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        guard let viewModel = viewModel else {
            return
        }
        squatCountLabel.text = "\(viewModel.squatCount)"
        pushupCountLabel.text = "\(viewModel.pushupCount)"
        plankCountLabel.text = "\(viewModel.plankCount)"
        completeLabel.text = "\(viewModel.totalComplete) 次每日計畫"
    }
}
