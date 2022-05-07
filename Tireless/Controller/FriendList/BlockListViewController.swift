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
    
    let viewModel = BlockListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "黑名單"
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.navigationController?.navigationBar.barTintColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(InviteFriendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(InviteFriendViewCell.self)")
        
        viewModel.blocksViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchBlocks()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
