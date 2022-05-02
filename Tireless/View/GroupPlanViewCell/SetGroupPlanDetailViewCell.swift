//
//  SetGroupPlanDetailViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class SetGroupPlanDetailViewCell: UICollectionViewCell {
    
    var isCreateButtonTap: ((String, String) -> Void)?
    
    @IBOutlet weak var groupCreatedUserLabel: UILabel!
    
    @IBOutlet weak var groupDaysLabel: UILabel!
    
    @IBOutlet weak var groupTimesLabel: UILabel!
    
    @IBOutlet weak var groupDaysCounterView: CounterView!
    
    @IBOutlet weak var groupTimesCounterView: CounterView!
    
    @IBOutlet weak var groupCreatePlanButton: UIButton!
    
    @IBOutlet weak var groupPlanDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        groupDaysLabel.font = .bold(size: 20)
        groupTimesLabel.font = .bold(size: 20)
        groupCreatedUserLabel.font = .bold(size: 20)
        groupCreatePlanButton.layer.cornerRadius = 15
        groupDaysCounterView.setInputField(7)
        groupTimesCounterView.setInputField(10)
        groupPlanDetailLabel.font = .regular(size: 20)
    }
    
    @IBAction func createPlanButton(_ sender: UIButton) {
        isCreateButtonTap?(groupDaysCounterView.getInputField(), groupTimesCounterView.getInputField())
    }
}
