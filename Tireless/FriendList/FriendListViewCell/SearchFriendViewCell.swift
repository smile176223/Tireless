//
//  SearchFirendViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import UIKit

class SearchFriendViewCell: UITableViewCell {
    
    @IBOutlet private weak var cellView: UIView!
    
    @IBOutlet private weak var userNameLabel: UILabel!
    
    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet weak var cellAddButon: UIButton!
    
    private var viewModel: FriendsViewModel?
    
    var addButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    @IBAction func addButtonTap(_ sender: UIButton) {
        addButtonTapped?()
    }
    
    private func setupLayout() {
        cellView.layer.cornerRadius = 20
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.contentMode = .scaleAspectFill
        cellAddButon.layer.cornerRadius = 15
    }
    
    private func layoutCell() {
        if viewModel?.user.picture != "" {
            userImageView.loadImage(viewModel?.user.picture)
        } else {
            userImageView.image = UIImage.placeHolder
        }
        userNameLabel.text = viewModel?.user.name
    }
}
