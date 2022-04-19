//
//  ShareWallViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation
import UIKit
import AVFoundation

class ShareWallViewCell: UITableViewCell {
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoTitleText: UILabel!
    
    @IBOutlet weak var videoContentText: UILabel!
    
    var avPlayer: AVPlayer?
    
    var viewModel: ShareViewModel?
    
    private var isPlaying = false
    
    func setup(viewModel: ShareViewModel) {
        self.viewModel = viewModel
        layoutCell()
        configureVideo()
    }
    
    func layoutCell() {
        videoTitleText.text = viewModel?.shareFile.shareName
        videoContentText.text = Date.dateFormatter.string(
            from: Date.init(milliseconds: viewModel?.shareFile.createdTime ?? 0))
    }
    
    func configureVideo() {
        guard let viewModel = viewModel else {
            return
        }
        avPlayer = AVPlayer(url: viewModel.shareFile.shareURL)
        
        let avPlayerView = AVPlayerLayer()
        avPlayerView.player = avPlayer
        avPlayerView.frame = contentView.bounds
        avPlayerView.videoGravity = .resizeAspectFill
        loopVideo(avPlayer: avPlayer ?? AVPlayer())
        videoView.layer.addSublayer(avPlayerView)
    }
    
    func loopVideo(avPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { _ in
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }
    }
    
    func replay() {
        if !isPlaying {
            avPlayer?.seek(to: .zero)
            play()
        }
    }
    
    func play() {
        avPlayer?.play()
        isPlaying = true
    }
    
    func pause() {
        avPlayer?.pause()
        isPlaying = false
    }
}
