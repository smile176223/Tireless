//
//  AddFriendViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/28.
//

import UIKit

class SearchFriendViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .themeBG
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        } else {
            tableView.tableHeaderView = UIView(frame: CGRect(x: .zero, y: .zero, width: .zero,
                                                             height: CGFloat.leastNonzeroMagnitude))
        }
        
        tableView.register(UINib(nibName: "\(SearchFriendHeaderView.self)", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(SearchFriendHeaderView.self)")
        
        tableView.register(UINib(nibName: "\(SearchFirendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SearchFirendViewCell.self)")
    }
}

extension SearchFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(SearchFirendViewCell.self)", for: indexPath) as? SearchFirendViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: "\(SearchFriendHeaderView.self)"
            ) as? SearchFriendHeaderView else {
                return nil
        }
        
        return headerView
    }
}
