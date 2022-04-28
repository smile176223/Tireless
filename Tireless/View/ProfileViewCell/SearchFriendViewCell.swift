//
//  SearchFirendViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import UIKit

class SearchFriendViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var cellUserName: UILabel!
    
    @IBOutlet weak var cellUserImageView: UIImageView!
    
    @IBOutlet weak var cellAddButon: UIButton!
    
    var viewModel: FriendsViewModel?
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func setup(viewModel: FriendsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func setupLayout() {
        cellView.layer.cornerRadius = 20
        cellUserImageView.layer.cornerRadius = cellUserImageView.frame.height / 2
        cellUserImageView.contentMode = .scaleAspectFill
        cellAddButon.layer.cornerRadius = 15
    }
    
    func layoutCell() {
        if viewModel?.user.picture != "" {
            cellUserImageView.loadImage(viewModel?.user.picture)
        } else {
            cellUserImageView.image = UIImage(named: "TirelessLogo")
        }
        cellUserName.text = viewModel?.user.name
    }
}
