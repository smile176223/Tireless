//
//  ShareCommentViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import UIKit

class ShareCommentViewCell: UITableViewCell {
    
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var commentNameLabel: UILabel!
    
    @IBOutlet weak var commentTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        commentImageView.layer.cornerRadius = commentImageView.frame.height / 2
    }
}
