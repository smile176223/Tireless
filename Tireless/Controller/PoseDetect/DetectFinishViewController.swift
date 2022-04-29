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
    
    var plan: Plan?
    
    var groupPlan: GroupPlan?
    
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
        if plan != nil {
            guard let plan = plan,
                  let days = Double(plan.planDays) else {
                return
            }
            let done = round(plan.progress * days) + 1
            let progress = done / days
            self.plan?.progress = progress
            self.plan?.finishTime.append(FinishTime(day: Int(done),
                                                            time: Date().millisecondsSince1970,
                                                            planTimes: plan.planTimes))
            updatePlan()
            if progress == 1 {
                finishPlan()
            }
        } else if groupPlan != nil {
            guard let groupPlan = groupPlan else {
                return
            }
        }
    }
    private func updatePlan() {
        guard let plan = plan else {
            return
        }
        planViewModel.updatePlan(plan: plan)
    }
    private func finishPlan() {
        guard let plan = plan else {
            return
        }
        planViewModel.finishPlan(plan: plan)
    }
}
