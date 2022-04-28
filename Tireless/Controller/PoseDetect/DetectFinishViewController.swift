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
    
    let videoManager = ShareManager()
    
    let planViewModel = PlanManageViewModel()
    
    var personalPlan: PersonalPlan?
    
    var isUserCanShare = true
    
    var isUserRejectRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButtonTap()
        
        finishButtonTap()
        
        uploadProgressShow()
        
        updateValue()
        
        if isUserRejectRecording == true {
            detectFinishView.shareButton.isHidden = true
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
//        if let tabBarController = self.presentingViewController?.presentingViewController as? UITabBarController {
//            tabBarController.selectedIndex = 0
//        }
    }

    private func shareButtonTap() {
        guard let videoURL = videoURL else {
            return
        }
        
        let testVideo = ShareFiles(userId: "liamTest",
                              shareName: UUID().uuidString,
                              shareURL: videoURL,
                              createdTime: Date().millisecondsSince1970,
                              content: "",
                              comment: nil)
        
        detectFinishView.isShareButtonTap = { [weak self] in
            if self?.isUserCanShare == true {
                self?.videoManager.uploadVideo(shareFile: testVideo) { result in
                    switch result {
                    case .success(let url):
                        self?.videoURL = url
                        self?.sharePresent()
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
        videoManager.uploadProgress = { [weak self] progress in
            self?.detectFinishView.lottieProgress(progress.fractionCompleted)
        }
    }
    
    private func updateValue() {
        guard let personalPlan = personalPlan,
              let days = Double(personalPlan.planDays) else {
            return
        }
        let done = round(personalPlan.progress * days) + 1
        let progress = done / days
        self.personalPlan?.progress = progress
        self.personalPlan?.finishTime.append(FinishTime(day: Int(done),
                                                        time: Date().millisecondsSince1970,
                                                        planTimes: personalPlan.planTimes))
        updatePlan()
        if progress == 1 {
            finishPlan()
        }
    }
    private func updatePlan() {
        guard let personalPlan = personalPlan else {
            return
        }
        planViewModel.updatePlan(personalPlan: personalPlan)
    }
    private func finishPlan() {
        guard let personalPlan = personalPlan else {
            return
        }
        planViewModel.finishPlan(personalPlan: personalPlan)
    }
}
