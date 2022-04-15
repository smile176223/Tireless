//
//  ShareWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import AVFoundation

class ShareWallViewController: UIViewController {
    
    var videoUrl: URL?
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    
        tableView.backgroundColor = .white
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        tableView.register(UINib(nibName: "\(ShareWallViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareWallViewCell.self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func videoPlay() {
        guard let videoURL = videoUrl else { return }
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer!)
        player?.play()
    }
}

extension ShareWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShareWallViewCell.self)",
            for: indexPath) as? ShareWallViewCell else {
            return UITableViewCell()
        }
        
        let color = [UIColor.red, UIColor.black, UIColor.white, UIColor.gray, UIColor.blue]
        
//        cell.contentView.backgroundColor = color[indexPath.row]
//
//        guard let videoURL = videoUrl else { return }
        player = AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/tireless-bdf0c.appspot.com/o/Videos%2FTest1?alt=media&token=386a6dc2-7133-4084-9af6-c41a7a22adc7")!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = cell.contentView.frame
        cell.contentView.layer.addSublayer(playerLayer!)
        player?.play()

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.top
        view.safeAreaLayoutGuide.layoutFrame.height
    }

}
