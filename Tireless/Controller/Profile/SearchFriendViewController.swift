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
        
        tableView.register(UINib(nibName: "\(SearchFriendViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SearchFriendViewCell.self)")
    }
}

extension SearchFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(SearchFriendViewCell.self)", for: indexPath) as? SearchFriendViewCell else {
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
        headerView.searchFriendBar.delegate = self
        
        return headerView
    }
}

extension SearchFriendViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        searchBar.resignFirstResponder()
        print(text)
    }
    
}
