//
//  FriendListViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class FriendListViewCell: UITableViewCell {
    
    @IBOutlet private weak var friendImageView: UIImageView!
    
    @IBOutlet private weak var friendNameLabel: UILabel!
    
    @IBOutlet private weak var friendSetButton: UIView!
    
    var viewModel: FriendsViewModel?
    
    var setButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setuLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        friendNameLabel.text = viewModel?.user.name
        friendImageView.loadImage(viewModel?.user.picture)
        if viewModel?.user.picture == "" {
            friendImageView.backgroundColor = .themeBGSecond
            friendImageView.image = UIImage.placeHolder
        }
    }
    
    private func setuLayout() {
        self.layer.cornerRadius = 15
        friendImageView.layer.cornerRadius = friendImageView.frame.height / 2
    }
    
    @IBAction func setButtonTap(_ sender: UIButton) {
        setButtonTapped?()
    }
    
}
