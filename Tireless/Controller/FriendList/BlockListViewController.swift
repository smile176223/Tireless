//
//  BlockListViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/4.
//

import UIKit

class BlockListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var emptyView = UIImageView()
    
    let viewModel = BlockListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "黑名單"
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.navigationController?.navigationBar.barTintColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
        setEmptyView()
        
        tableView.register(UINib(nibName: "\(InviteFriendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(InviteFriendViewCell.self)")
        
        viewModel.blocksViewModels.bind { [weak self] blocks in
            DispatchQueue.main.async {
                if blocks.count == 0 {
                    self?.tableView.isHidden = true
                    self?.emptyView.isHidden = false
                } else {
                    self?.tableView.isHidden = false
                    self?.emptyView.isHidden = true
                }
                self?.tableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchBlocks()
    }
    
    private func setEmptyView() {
        emptyView.image = UIImage(named: "tireless_nodata")
        emptyView.contentMode = .scaleAspectFit
        self.view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            emptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2)
        ])
    }
}

extension BlockListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.blocksViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(InviteFriendViewCell.self)", for: indexPath) as? InviteFriendViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = self.viewModel.blocksViewModels.value[indexPath.row]
        cell.setupBlock(viewModel: cellViewModel)
        
        cell.isRejectButtonTap = { [weak self] in
            self?.presentRemoveAlert(userId: cellViewModel.user.userId)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension BlockListViewController {
    private func presentRemoveAlert(userId: String) {
        let okAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            self.viewModel.removeBlockUser(userId: userId)
        }
        let cancel = UIAlertAction.cancelAction
        let actions = [okAction, cancel]
        presentAlert(withTitle: "確認是否將該使用者移除黑名單",
                     message: "移除黑名單後，您將再次看到該使用者的資訊",
                     style: .alert,
                     actions: actions)
    }
}
