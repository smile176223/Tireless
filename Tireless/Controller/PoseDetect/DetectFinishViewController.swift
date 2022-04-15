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
    
    var videoURL: URL?
    
    let videoManager = VideoManager()
    
    var isUserCanShare = false
    
    var isUserRejectRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButtonTap()
        
        finishButtonTap()
        
        uploadProgressShow()
        
        if isUserRejectRecording == true {
            detectFinishView.shareButton.isHidden = true
        }
    }
    
    private func finishPresent() {
        guard let shareVC = UIStoryboard.shareWall.instantiateViewController(
            withIdentifier: "\(ShareWallViewController.self)")
                as? ShareWallViewController
        else {
            return
        }
        shareVC.videoURL = videoURL
        self.navigationController?.pushViewController(shareVC, animated: true)
        
    }
    private func shareButtonTap() {
        guard let videoURL = videoURL else {
            return
        }
        
        let testVideo = Video(userId: "liamTest",
                              video: "Test1",
                              videoURL: videoURL,
                              createTime: Date().millisecondsSince1970,
                              content: "",
                              comment: nil)
        
        detectFinishView.isShareButtonTap = { [weak self] in
            if self?.isUserCanShare == true {
                self?.videoManager.uploadVideo(video: testVideo) { result in
                    switch result {
                    case .success(let url):
                        self?.videoURL = url
                        self?.finishPresent()
                    case .failure(let error):
                        print("error", error)
                    }
                }
            } else {
                let alertController = UIAlertController(title: "上傳次數上限三次", message: "作者沒有錢錢了!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "忍痛放棄", style: .default) { _ in
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(okAction)
                self?.present(alertController, animated: true)
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
