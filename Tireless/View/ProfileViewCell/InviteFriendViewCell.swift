//
//  InviteFriendViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import UIKit

class InviteFriendViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    var viewModel: FriendsViewModel?
    
    var isAgreeButtonTap: (() -> Void)?
    
    var isRejectButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func setupLayout() {
        cellView.layer.cornerRadius = 20
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.contentMode = .scaleAspectFill
        agreeButton.layer.cornerRadius = 15
        rejectButton.layer.cornerRadius = 15
    }
    
    func layoutCell() {
        if viewModel?.user.picture != "" {
            userImageView.loadImage(viewModel?.user.picture)
        } else {
            userImageView.image = UIImage(named: "TirelessLogo")
        }
        userNameLabel.text = viewModel?.user.name
    }
    
    @IBAction func agreeButtonTap(_ sender: UIButton) {
        isAgreeButtonTap?()
    }
    
    @IBAction func rejectButtonTap(_ sender: UIButton) {
        isRejectButtonTap?()
    }
    
}
