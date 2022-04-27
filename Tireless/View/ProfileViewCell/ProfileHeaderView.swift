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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
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
    
    private func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: "\(ProfileHeaderView.self)", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupLayout() {
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.gray.cgColor
        headerLineView.layer.cornerRadius = 5
        userNameLabel.font = .bold(size: 20)
    }
}
