//
//  ShareCommentViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/30.
//

import UIKit

class ShareCommentViewController: UIViewController {
    
    @IBOutlet private weak var commentView: UIView!
    
    @IBOutlet private weak var commentLineView: UIView!
    
    @IBOutlet private weak var commentTextField: UITextField!
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private let maskView = UIView(frame: UIScreen.main.bounds)

    var viewModel: ShareCommentViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMaskView()
        setupLayout()
        
        tableView.register(UINib(nibName: "\(ShareCommentViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareCommentViewCell.self)")
        
        viewModel?.comments.bind { _ in
            self.tableView.reloadData()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.fetchData()
    }
    
    private func setupLayout() {
        commentView.clipsToBounds = true
        commentView.layer.cornerRadius = 20
        commentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        commentLineView.layer.cornerRadius = 5
        commentTextField.attributedPlaceholder = NSAttributedString(string: "加入評論...",
                                                                  attributes: [.foregroundColor: UIColor.lightGray])
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
        if commentTextField.text?.isEmpty == true {
            return
        }
        guard let commentText = commentTextField.text else {
            return
        }
        viewModel?.sendComment(comment: commentText, needLogin: {
            if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
                self.maskView.removeFromSuperview()
                self.present(authVC, animated: true, completion: nil)
            }
        })
        commentTextField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            maskView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setButtonAlert(userId: String) {
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            self.viewModel?.blockUser(userId: userId)
        }
        let cancelAction = UIAlertAction.cancelAction
        let actions = [banAction, cancelAction]
        presentAlert(style: .actionSheet, actions: actions)
    }
}

extension ShareCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.comments.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(ShareCommentViewCell.self)", for: indexPath) as? ShareCommentViewCell else {
            return UITableViewCell()
        }
        guard let cellComment = self.viewModel?.comments.value[indexPath.row] else {
            return cell
        }
        
        cell.setup(comment: cellComment)
        
        cell.setButtonTapped = { [weak self] in
            self?.setButtonAlert(userId: cellComment.userId)
        }
        
        return cell
    }
    
}
