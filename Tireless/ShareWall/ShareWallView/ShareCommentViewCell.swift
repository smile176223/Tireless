//
//  ShareCommentViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import UIKit

class ShareCommentViewCell: UITableViewCell {
    
    @IBOutlet private weak var commentImageView: UIImageView!
    
    @IBOutlet private weak var commentNameLabel: UILabel!
    
    @IBOutlet private weak var commentTextLabel: UILabel!
    
    @IBOutlet private weak var setButton: UIButton!
    
    private var comment: Comment?
    
    var setButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(comment: Comment) {
        self.comment = comment
        layoutCell()
    }
    
    private func layoutCell() {
        if comment?.user?.picture == "" {
            commentImageView.image = UIImage.placeHolder
        } else {
            commentImageView.loadImage(comment?.user?.picture)
        }
        commentNameLabel.text = comment?.user?.name
        commentTextLabel.text = comment?.content
        if comment?.userId == AuthManager.shared.currentUser {
            setButton.isHidden = true
        } else {
            setButton.isHidden = false
        }
    }
    
    private func setupLayout() {
        commentImageView.layer.cornerRadius = commentImageView.frame.height / 2
    }
    @IBAction func setButtonTap(_ sender: UIButton) {
        setButtonTapped?()
    }
}
