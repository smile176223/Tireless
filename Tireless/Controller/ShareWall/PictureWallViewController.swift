//
//  PictureWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/17.
//

import Foundation
import UIKit

class PictureWallViewController: UIViewController {
    
    let videoManager = VideoManager()
    
    var pictures: [Picture]? {
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
        
        tableView.backgroundColor = .white
        
        tableView.register(UINib(nibName: "\(SharePictureViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SharePictureViewCell.self)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoManager.fetchPicture { result in
            switch result {
            case .success(let pictures):
                self.pictures = pictures
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension PictureWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SharePictureViewCell.self)",
            for: indexPath) as? SharePictureViewCell else {
            return UITableViewCell()
        }
        guard let pictures = pictures else { return UITableViewCell()}
        cell.pictureTitle.text = "\(pictures[indexPath.row].pictureName)"
        cell.pictureDate.text = "\(pictures[indexPath.row].createdTime)"
        cell.pictureImageView.loadImage("\(pictures[indexPath.row].pictureURL)")
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
