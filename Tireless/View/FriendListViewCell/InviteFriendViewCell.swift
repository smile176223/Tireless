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
    
    var blocksViewModel: BlocksViewModel?
    
    var agreeButtonTapped: (() -> Void)?
    
    var rejectButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func setupLayout() {
        cellView.layer.cornerRadius = 20
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.contentMode = .scaleAspectFill
        agreeButton.layer.cornerRadius = 15
        rejectButton.layer.cornerRadius = 15
    }
    
    func setupBlock(viewModel: BlocksViewModel) {
        self.blocksViewModel = viewModel
        layoutBlockCell()
    }
    
    private func layoutCell() {
        if viewModel?.user.picture != "" {
            userImageView.loadImage(viewModel?.user.picture)
        } else {
            userImageView.image = UIImage.placeHolder
        }
        userNameLabel.text = viewModel?.user.name
    }
    
    private func layoutBlockCell() {
        agreeButton.isHidden = true
        if blocksViewModel?.user.picture != "" {
            userImageView.loadImage(blocksViewModel?.user.picture)
        } else {
            userImageView.image = UIImage.placeHolder
        }
        userNameLabel.text = blocksViewModel?.user.name
    }
    
    @IBAction func agreeButtonTap(_ sender: UIButton) {
        agreeButtonTapped?()
    }
    
    @IBAction func rejectButtonTap(_ sender: UIButton) {
        rejectButtonTapped?()
    }
    
}
