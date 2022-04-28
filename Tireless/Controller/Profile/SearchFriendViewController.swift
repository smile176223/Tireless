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
    
    let viewModel = SearchFriendViewModel()
    
    var checkList = [String]()
    
    var friendList: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .themeBG
        
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
        
        viewModel.friendViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        makeCheckList()
    }
    private func makeCheckList() {
        guard let friendList = friendList else {
            return
        }
        for friend in friendList {
            self.checkList.append(friend.userId)
        }
    }
}

extension SearchFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.friendViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(SearchFriendViewCell.self)", for: indexPath) as? SearchFriendViewCell else {
            return UITableViewCell()
        }
        let cellViewModel = self.viewModel.friendViewModels.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        if checkList.contains(cellViewModel.user.userId) == true {
            cell.cellAddButon.isHidden = true
        } else {
            cell.cellAddButon.isHidden = false
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
        viewModel.searchFriend(name: text)
        searchBar.resignFirstResponder()
    }
    
}
