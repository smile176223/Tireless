//
//  DetectFinishViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/11.
//

import UIKit
import SwiftUI

class DetectFinishViewController: UIViewController {
    
    @IBOutlet var detectFinishView: DetectFinishView!
    
    var videoUrl: URL?
    
    let videoManager = VideoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButtonTap()
        
        finishButtonTap()
        
        uploadProgressShow()
    }
    
    private func finishPresent() {
        guard let shareVC = storyboard?.instantiateViewController(
            withIdentifier: "\(ShareWallViewController.self)")
                as? ShareWallViewController
        else {
            return
        }
        shareVC.videoUrl = videoUrl
        self.navigationController?.pushViewController(shareVC, animated: true)
        
    }
    private func shareButtonTap() {
        guard let videoUrl = videoUrl else {
            return
        }
        detectFinishView.isShareButtonTap = { [weak self] in
            self?.videoManager.uploadVideo(video: Video(id: "123", video: "test2", videoURL: videoUrl)) { result in
                switch result {
                case .success(let url):
                    self?.videoUrl = url
                    self?.finishPresent()
                case .failure(let error):
                    print("error", error)
                }
            }
        }
    }
    
    private func finishButtonTap() {
        detectFinishView.isFinishButtonTap = { [weak self] in
            self?.finishPresent()
            
        }
    }
    
    private func uploadProgressShow() {
        videoManager.uploadProgress = { progress in
            self.detectFinishView.lottieProgress(progress.fractionCompleted)
        }
    }
}
