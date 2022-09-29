//
//  HomeDailyViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import Foundation
import UIKit

class HomeDailyViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var dailyWeekDayLabel: UILabel!
    
    @IBOutlet private weak var dailyDayLabel: UILabel!
    
    private var weekDays: WeeklyDays?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        self.layer.cornerRadius = 12
        self.isUserInteractionEnabled = false
    }
    
    func setup(weekDays: WeeklyDays, index: IndexPath) {
        self.weekDays = weekDays
        layoutCell(index: index)
    }
    
    private func layoutCell(index: IndexPath) {
        dailyDayLabel.text = weekDays?.days
        dailyWeekDayLabel.text = weekDays?.weekDays
        if index.row == 2 {
            self.contentView.backgroundColor = .themeYellow
        } else {
            self.contentView.backgroundColor = .white
        }
    }
}
