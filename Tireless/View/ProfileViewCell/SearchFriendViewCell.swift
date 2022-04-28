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
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func setupLayout() {
        cellView.layer.cornerRadius = 20
        cellUserImageView.layer.cornerRadius = cellUserImageView.frame.height / 2
        cellAddButon.layer.cornerRadius = 15
    }
}
