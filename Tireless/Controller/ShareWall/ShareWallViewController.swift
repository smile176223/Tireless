//
//  ShareWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import AVFoundation

class ShareWallViewController: UIViewController {
    
    var videoURL: URL?
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    let viewModel = ShareWallViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        tableView.backgroundColor = .white
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.register(UINib(nibName: "\(ShareWallViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareWallViewCell.self)")
        
        viewModel.shareViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
//        viewModel.fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        viewModel.fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension ShareWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.shareViewModel.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShareWallViewCell.self)",
            for: indexPath) as? ShareWallViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = self.viewModel.shareViewModel.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        let cellVideoUrl = self.viewModel.shareViewModel.value[indexPath.row].shareFile.shareURL
        
        player = AVPlayer(url: cellVideoUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = cell.contentView.frame
        cell.videoView.layer.addSublayer(playerLayer!)
        player?.play()

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.top
    }
}

extension ShareWallViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        player?.seek(to: .zero)
    }
}
