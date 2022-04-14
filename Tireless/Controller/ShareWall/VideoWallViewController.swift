//
//  ShareWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import AVFoundation

class VideoWallViewController: UIViewController {
    
    var videoUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .white
        
        videoPlay()
    
    }

    func videoPlay() {
        guard let videoURL = videoUrl else { return }
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        player.play()
    }
}

extension VideoWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
