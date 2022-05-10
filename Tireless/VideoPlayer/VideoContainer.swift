//
//  VideoContainer.swift
//  Tireless
//
//  Created by Hao on 2022/5/9.
//
import UIKit
import AVFoundation

class VideoContainer {
    var url: String
    var playOn: Bool {
        didSet {
            player.isMuted = VideoPlayerController.sharedVideoPlayer.mute
            playerItem.preferredPeakBitRate = VideoPlayerController.sharedVideoPlayer.preferredPeakBitRate
            if playOn && playerItem.status == .readyToPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    
    let player: AVPlayer
    let playerItem: AVPlayerItem
    
    init(player: AVPlayer, item: AVPlayerItem, url: String) {
        self.player = player
        self.playerItem = item
        self.url = url
        playOn = false
    }
}
