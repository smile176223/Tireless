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
        playerLayer.frame = view.layer.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
}
