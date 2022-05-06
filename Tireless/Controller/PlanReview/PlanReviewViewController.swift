//
//  PlanReviewViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/5.
//

import UIKit
import AVFoundation
import AVKit

class PlanReviewViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var plan: Plan?
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    
    let viewModel = PlanReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "計畫進度"
        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
        tableView.register(UINib(nibName: "\(PlanReviewHeaderView.self)", bundle: nil),
                                 forHeaderFooterViewReuseIdentifier: "\(PlanReviewHeaderView.self)")
        
        tableView.register(UINib(nibName: "\(PlanReviewViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(PlanReviewViewCell.self)")

        fetchPlanReview()
        
        viewModel.finishTimeViewModels.bind { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPlanReview() {
        guard let finishTime = plan?.finishTime else {
            return
        }
        viewModel.fetchPlanReview(finishTime: finishTime)
    }
    
    func playVideo(videoURL: String) {
        if let videoURL = URL(string: videoURL) {
            self.player = AVPlayer(url: videoURL)
        }
        self.playerViewController = AVPlayerViewController()
        playerViewController?.player = self.player
        playerViewController?.view.frame = self.view.frame
        playerViewController?.player?.pause()
        guard let playerViewController = playerViewController else {
            return
        }
        present(playerViewController, animated: true)
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "無影片",
                                                message: "使用者未上傳影片!",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}

extension PlanReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.finishTimeViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(PlanReviewViewCell.self)", for: indexPath) as? PlanReviewViewCell else {
            return UITableViewCell()
        }
        let cellViewModel = self.viewModel.finishTimeViewModels.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)

        cell.isPlayButtonTap = { [weak self] in
            guard let url = cellViewModel.finishTime.videoURL else { return }
            self?.playVideo(videoURL: url)
        }
        
        cell.isNoVideoButtonTap = { [weak self] in
            self?.showAlert()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "\(PlanReviewHeaderView.self)")
                as? PlanReviewHeaderView else {
            return UIView()
        }
        if let plan = plan {
            header.planImageView.image = UIImage(named: plan.planName)
            header.planNameLabel.text = plan.planName
            header.planTImesLabel.text = "每天\(plan.planTimes)秒/次，持續\(plan.planDays)天"
            header.planProgressBar.progress = Float(plan.progress)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        130
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
}
