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
    
    @IBOutlet weak var setButton: UIButton!
    
    var viewModel: Comment?
    
    var isSetButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: Comment) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func layoutCell() {
        if viewModel?.user?.picture == "" {
            commentImageView.image = UIImage.placeHolder
        } else {
            commentImageView.loadImage(viewModel?.user?.picture)
        }
        commentNameLabel.text = viewModel?.user?.name
        commentTextLabel.text = viewModel?.content
        if viewModel?.userId == AuthManager.shared.currentUser {
            setButton.isHidden = true
        } else {
            setButton.isHidden = false
        }
    }
    
    private func setupLayout() {
        commentImageView.layer.cornerRadius = commentImageView.frame.height / 2
    }
    @IBAction func setButtonTap(_ sender: UIButton) {
        isSetButtonTap?()
    }
}
