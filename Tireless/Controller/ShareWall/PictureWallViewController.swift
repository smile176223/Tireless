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
        
        tableView.register(UINib(nibName: "\(SharePictureViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SharePictureViewCell.self)")
        
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
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SharePictureViewCell.self)",
            for: indexPath) as? SharePictureViewCell else {
            return UITableViewCell()
        }
        
        cell.pictureTitle.text = "test"
        cell.pictureImageView.image = UIImage(named: "TirelessLogo")
        cell.pictureImageView.contentMode = .scaleAspectFill
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
}
