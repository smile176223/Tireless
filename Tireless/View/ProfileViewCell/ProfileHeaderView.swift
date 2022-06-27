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

    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var indicatorCenterX: NSLayoutConstraint!
    
    var userImageTapped: (() -> Void)?
    
    var countTapped: (() -> Void)?
    
    var historyTapped: (() -> Void)?
    
    var awardTapped: (() -> Void)?
    
    var setListButtonTapped: (() -> Void)?
    
    var bellAlertButtonTapped: (() -> Void)?
    
    var friendsButtonTapped: (() -> Void)?
    
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
        userImageTapped?()
    }
    
    @IBAction func countTabButtonTap(_ sender: UIButton) {
        indicatorAnimate(sender)
        countTapped?()
    }
    
    @IBAction func historyabButtonTap(_ sender: UIButton) {
        indicatorAnimate(sender)
        historyTapped?()
    }
    
    @IBAction func awardButtonTap(_ sender: UIButton) {
        indicatorAnimate(sender)
        awardTapped?()
    }
    
    @IBAction func blockListButtonTap(_ sender: UIButton) {
        setListButtonTapped?()
    }
    
    @IBAction func bellAlertButtonTap(_ sender: UIButton) {
        bellAlertButtonTapped?()
    }
    
    @IBAction func friendsButtonTap(_ sender: UIButton) {
        friendsButtonTapped?()
    }
    
    private func setupLayout() {
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.gray.cgColor
        headerLineView.layer.cornerRadius = 5
        userNameLabel.font = .bold(size: 20)
        indicatorView.layer.cornerRadius = 15
    }
    
    private func indicatorAnimate(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.indicatorCenterX.isActive = false
            self.indicatorCenterX = self.indicatorView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            self.indicatorCenterX.isActive = true
        }, completion: nil)
    }
}
