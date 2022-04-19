//
//  PictureWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/17.
//

import Foundation
import UIKit

class PictureWallViewController: UIViewController {
    
    let shareManager = ShareManager()
    
    var shareFiles: [ShareFiles]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(SharePictureViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SharePictureViewCell.self)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shareManager.fetchPicture { result in
            switch result {
            case .success(let shareFiles):
                self.shareFiles = shareFiles
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension PictureWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shareFiles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SharePictureViewCell.self)",
            for: indexPath) as? SharePictureViewCell else {
            return UITableViewCell()
        }
        guard let shareFiles = shareFiles else { return UITableViewCell()}
        cell.pictureTitle.text = "\(shareFiles[indexPath.row].shareName)"
        cell.pictureDate.text = "\(shareFiles[indexPath.row].createdTime)"
        cell.pictureImageView.loadImage("\(shareFiles[indexPath.row].shareURL)")
        cell.pictureImageView.contentMode = .scaleAspectFill
        
        cell.pictureTitle.textColor = .black
        cell.pictureDate.textColor = .black
        
        cell.backgroundColor = .white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        350
    }
}
