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
    
    var shareFile: ShareFiles?
    
    let viewModel = ShareCommentViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMaskView()
        setupLayout()
        
        tableView.register(UINib(nibName: "\(ShareCommentViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareCommentViewCell.self)")
        
        viewModel.commentsViewModel.bind { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let shareFile = shareFile else {
            return
        }
        viewModel.fetchData(uuid: shareFile.uuid)
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
        if commentTextField.text?.isEmpty == true {
            return
        }
        if AuthManager.shared.checkCurrentUser() == true {
            guard let shareFile = shareFile,
                  let commentText = commentTextField.text else {
                return
            }
            CommentManager.shared.postComment(uuid: shareFile.uuid,
                                              comment: Comment(userId: AuthManager.shared.currentUser,
                                                               content: commentText,
                                                               createdTime: Date().millisecondsSince1970)) { result in
                switch result {
                case .success(let text):
                    print(text)
                case .failure(let error):
                    print(error)
                }
            }
            commentTextField.text = ""
        } else {
            if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
                maskView.removeFromSuperview()
                present(authVC, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            maskView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setButtonAlert(userId: String) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            UserManager.shared.blockUser(blockId: userId) { result in
                switch result {
                case .success(let text):
                    print(text)
                    ProgressHUD.showSuccess(text: "封鎖成功")
                case .failure(let error):
                    print(error)
                    ProgressHUD.showFailure(text: "封鎖失敗")
                    
                }
            }
        }
        controller.addAction(banAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
}

extension ShareCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.commentsViewModel.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(ShareCommentViewCell.self)", for: indexPath) as? ShareCommentViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = self.viewModel.commentsViewModel.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        cell.isSetButtonTap = { [weak self] in
            self?.setButtonAlert(userId: cellViewModel.comment.userId)
        }
        
        return cell
    }
    
}
