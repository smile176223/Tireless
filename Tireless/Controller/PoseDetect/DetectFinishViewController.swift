//
//  DetectFinishViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/11.
//

import UIKit

class DetectFinishViewController: UIViewController {
    
    @IBOutlet var detectFinishView: DetectFinishView!
    
    let videoManager = ShareManager()
    
    var viewModel: DetectFinishViewModel?
    
    var recordStatus: RecordStatus = .userAgree
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButtonTap()
        
        finishButtonTap()
        
        viewModel?.uploadProgress()
        
        setupBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel?.recordStatus == .userReject {
            detectFinishView.shareButton.isHidden = true
        }
    }

    private func shareButtonTap() {
        detectFinishView.isShareButtonTap = { [weak self] in
            self?.changeButtonStatus(status: false)
            self?.viewModel?.uploadVideo()
        }
    }
    
    private func setupBind() {
        viewModel?.progress.bind { [weak self] progress in
            guard let progress = progress else {
                return
            }
            self?.detectFinishView.lottieProgress(progress.fractionCompleted)
        }
        
        viewModel?.uploadStatus.bind { bool in
            guard let bool = bool else {
                return
            }
            if bool == true {
                self.sharePresent()
                self.changeButtonStatus(status: true)
            } else {
                self.changeButtonStatus(status: true)
            }
        }
    }
    
    private func changeButtonStatus(status: Bool) {
        self.detectFinishView.shareButton.isEnabled = status
        self.detectFinishView.downButton.isEnabled = status
    }
    
    private func finishButtonTap() {
        detectFinishView.isFinishButtonTap = { [weak self] in
            self?.viewModel?.updateValue(videoId: "")
            self?.finishPresent()
        }
    }
    
    private func sharePresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let tabBarController = self.presentingViewController?.presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 2
        }
    }
    
    private func finishPresent() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}
