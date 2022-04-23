//
//  HomeDailyViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/20.
//

import Foundation
import UIKit

class HomeDailyViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dailyWeekDayLabel: UILabel!
    
    @IBOutlet weak var dailyDayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setupLayout() {
        self.layer.cornerRadius = 12
        self.isUserInteractionEnabled = false
    }
}
