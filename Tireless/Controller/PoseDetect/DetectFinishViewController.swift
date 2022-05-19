//
//  DetectFinishViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/11.
//

import UIKit

class DetectFinishViewController: UIViewController {
    
    @IBOutlet var detectFinishView: DetectFinishView!
    
    var videoURL: URL?
    
    let videoManager = ShareManager()
    
    var viewModel: DetectFinishViewModel?
    
    let planViewModel = PlanManageViewModel()
    
    var plan: Plan?
    
    var recordStatus: RecordStatus = .userAgree
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButtonTap()
        
        finishButtonTap()
        
        uploadProgressShow()
        
        if viewModel?.recordStatus == .userReject {
            detectFinishView.shareButton.isHidden = true
        }
        
//        if recordStatus == .userReject {
//            detectFinishView.shareButton.isHidden = true
//        }
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

    private func shareButtonTap() {
        guard let videoURL = videoURL else {
            return
        }
        
        let uploadVideo = ShareFiles(userId: AuthManager.shared.currentUser,
                                   shareName: AuthManager.shared.currentUserData?.name ?? "Tireless",
                                   shareURL: videoURL,
                                   createdTime: Date().millisecondsSince1970,
                                     content: "\(plan?.planName ?? "")每日\(plan?.planTimes ?? "")次/秒 挑戰!",
                                   uuid: "")
        
        detectFinishView.isShareButtonTap = { [weak self] in
            self?.changeButtonStatus(status: false)
            self?.videoManager.uploadVideo(shareFile: uploadVideo) { result in
                switch result {
                case .success(let uuid):
                    self?.updateValue(videoId: uuid)
                    self?.sharePresent()
                    self?.changeButtonStatus(status: true)
                case .failure(let error):
                    print("error", error)
                    self?.changeButtonStatus(status: true)
                }
            }
        }
    }
    
    private func changeButtonStatus(status: Bool) {
        self.detectFinishView.shareButton.isEnabled = status
        self.detectFinishView.downButton.isEnabled = status
    }
    
    private func finishButtonTap() {
        detectFinishView.isFinishButtonTap = { [weak self] in
            self?.updateValue(videoId: "")
            self?.finishPresent()
        }
    }
    
    private func uploadProgressShow() {
        videoManager.uploadProgress = { [weak self] progress in
            self?.detectFinishView.lottieProgress(progress.fractionCompleted)
        }
    }
    
    private func updateValue(videoId: String) {
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
                                                    planTimes: plan.planTimes,
                                                    videoId: videoId))
            updatePlan()
            if progress == 1 {
                finishPlan()
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
