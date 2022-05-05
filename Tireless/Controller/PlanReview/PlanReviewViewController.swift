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

        self.navigationController?.navigationBar.backgroundColor = .themeBG
        self.view.backgroundColor = .themeBG
        self.tableView.backgroundColor = .themeBG
        
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
    
    func video(videoURL: String) {
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
            self?.video(videoURL: url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
}
