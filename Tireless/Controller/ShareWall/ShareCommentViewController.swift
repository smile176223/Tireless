//
//  ShareCommentViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import UIKit

class ShareCommentViewController: UIViewController {
    
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var commentLineView: UIView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    let maskView = UIView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMaskView()
        setupLayout()
        
        tableView.register(UINib(nibName: "\(ShareCommentViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareCommentViewCell.self)")
        
    }
    
    private func setupLayout() {
        commentView.clipsToBounds = true
        commentView.layer.cornerRadius = 20
        commentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        commentLineView.layer.cornerRadius = 5
        commentTextField.attributedPlaceholder = NSAttributedString(string: "加入評論...",
                                                                  attributes: [.foregroundColor: UIColor.white])
        self.tableView.backgroundColor = .themeBG
    }
    
    private func setMaskView() {
        maskView.backgroundColor = .black
        maskView.alpha = 0
        presentingViewController?.view.addSubview(maskView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.maskView.alpha = 0.5
        }
    }
    @IBAction func sendCommentTap(_ sender: UIButton) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            maskView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ShareCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(ShareCommentViewCell.self)", for: indexPath) as? ShareCommentViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
}
