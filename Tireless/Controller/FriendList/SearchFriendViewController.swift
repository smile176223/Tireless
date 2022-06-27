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
    
    private var searchEmptyView = UIImageView()
    
    var viewModel: SearchFriendViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        
        self.view.backgroundColor = .themeBG
        
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
        
        viewModel?.friendViewModels.bind { [weak self] user in
            if user.isEmpty {
                self?.setSearchEmptyView()
            } else {
                self?.searchEmptyView.removeFromSuperview()
            }
            self?.tableView.reloadData()
        }
        
        makeCheckList()
        
    }
    private func makeCheckList() {
        viewModel?.checkFriendsList()
    }
    
    private func setSearchEmptyView() {
        searchEmptyView.removeFromSuperview()
        searchEmptyView.image = UIImage(named: "tireless_nouser")
        searchEmptyView.contentMode = .scaleAspectFit
        self.view.addSubview(searchEmptyView)
        searchEmptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchEmptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            searchEmptyView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            searchEmptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            searchEmptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2)
        ])
        
    }
}

extension SearchFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.friendViewModels.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(SearchFriendViewCell.self)", for: indexPath) as? SearchFriendViewCell else {
            return UITableViewCell()
        }
        
        guard let cellViewModel = self.viewModel?.friendViewModels.value[indexPath.row],
              let viewModel = viewModel else {
            return UITableViewCell()
        }
        cell.setup(viewModel: cellViewModel)

        if viewModel.checkSearch(userId: cellViewModel.user.userId) {
            cell.cellAddButon.isHidden = true
        } else {
            cell.cellAddButon.isHidden = false
        }
        
        cell.addButtonTapped = {
            viewModel.inviteFriend(userId: cellViewModel.user.userId)
            ProgressHUD.showSuccess(text: "發送邀請")
            cell.cellAddButon.isHidden = true
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
        viewModel?.searchFriend(name: text)
        searchBar.resignFirstResponder()
    }
    
}
