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
    
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var setButton: CustomButton!
    
    var avPlayer: AVPlayer?
    
    var viewModel: ShareFilesViewModel?
    
    var isCommentButtonTap: (() -> Void)?
    
    var isSetButtonTap: (() -> Void)?
    
    private var isPlaying = false
    
    func setup(viewModel: ShareFilesViewModel) {
        self.viewModel = viewModel
        layoutCell()
        configureVideo()
        setupLayout()
    }
    
    func layoutCell() {
        videoTitleText.text = viewModel?.shareFile.shareName
        let date = Date.dateFormatter.string(
            from: Date.init(milliseconds: viewModel?.shareFile.createdTime ?? 0))
        videoContentText.text = "\(viewModel?.shareFile.content ?? "")\n\(date)"
    }
    
    func setupLayout() {
        setButton.touchEdgeInsets = UIEdgeInsets(top: -15, left: -10, bottom: -15, right: -10)
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
    
    @IBAction func commentButtonTap(_ sender: UIButton) {
        isCommentButtonTap?()
    }
    @IBAction func setButtonTqp(_ sender: UIButton) {
        isSetButtonTap?()
    }
    
}
