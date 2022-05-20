//
//  DetectFinishViewModel.swift
//  Tireless
//
//  Created by Hao on 2022/5/19.
//

import Foundation

class DetectFinishViewModel {
    
    var plan: Plan
    
    var videoURL: URL?
    
    let progress: Box<Progress?> = Box(nil)
    
    let uploadStatus: Box<Bool?> = Box(nil)
    
    var recordStatus: RecordStatus = .userAgree
    
    let shareManager = ShareManager()
    
    let planViewModel = PlanManageViewModel()

    init(plan: Plan, videoURL: URL?) {
        self.plan = plan
        self.videoURL = videoURL
    }
    
    func uploadVideo() {
        guard let videoURL = videoURL else {
            return
        }
        let uploadVideo = ShareFiles(userId: AuthManager.shared.currentUser,
                                     shareName: AuthManager.shared.currentUserData?.name ?? "Tireless",
                                     shareURL: videoURL,
                                     createdTime: Date().millisecondsSince1970,
                                     content: "\(plan.planName)每日\(plan.planTimes)次/秒 挑戰!",
                                     uuid: "")
        
        self.shareManager.uploadVideo(shareFile: uploadVideo) { result in
            switch result {
            case .success(let uuid):
                self.updateValue(videoId: uuid)
                self.uploadStatus.value = true
            case .failure(let error):
                print(error)
                self.uploadStatus.value = false
            }
        }
    }
    
    func updateValue(videoId: String) {
            guard let days = Double(plan.planDays) else {
                return
            }
            let done = round(plan.progress * days) + 1
            let progress = done / days
            self.plan.progress = progress
            self.plan.finishTime.append(FinishTime(day: Int(done),
                                                    time: Date().millisecondsSince1970,
                                                    planTimes: plan.planTimes,
                                                    videoId: videoId))
            updatePlan()
            if progress == 1 {
                finishPlan()
            }
    }
    
    private func updatePlan() {
        planViewModel.updatePlan(plan: plan)
    }
    private func finishPlan() {
        planViewModel.finishPlan(plan: plan)
    }
    
    func uploadProgress() {
        shareManager.uploadProgress = { [weak self] progress in
            self?.progress.value = progress
        }
    }
    
}
