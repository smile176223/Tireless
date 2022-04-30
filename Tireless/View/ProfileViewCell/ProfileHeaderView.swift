//
//  ProfileHeaderView.swift
//  Tireless
//
//  Created by Hao on 2022/4/24.
//

import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var headerLineView: UIView!
    
    var isUserImageTap: (() -> Void)?
    
    var isSearchButtonTap: (() -> Void)?
    
    var isInviteTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        imageViewTap()
    }
    
    private func imageViewTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(imageTapped(tapGestureRecognizer:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        isUserImageTap?()
    }
    
    @IBAction func searchButtonTap(_ sender: UIButton) {
        isSearchButtonTap?()
    }
    
    @IBAction func inviteTap(_ sender: Any) {
        isInviteTap?()
    }
    
    private func setupLayout() {
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.gray.cgColor
        headerLineView.layer.cornerRadius = 5
        userNameLabel.font = .bold(size: 20)
    }
}
