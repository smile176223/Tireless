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
    
    var viewModel: CommentsViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: CommentsViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func layoutCell() {
        if viewModel?.comment.user?.picture == "" {
            commentImageView.image = UIImage(named: "TirelessLogo")
        } else {
            commentImageView.loadImage(viewModel?.comment.user?.picture)
        }
        commentNameLabel.text = viewModel?.comment.user?.name
        commentTextLabel.text = viewModel?.comment.content
    }
    
    private func setupLayout() {
        commentImageView.layer.cornerRadius = commentImageView.frame.height / 2
    }
}
