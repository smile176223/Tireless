//
//  ShareWallViewController.swift
//  Tireless
//
//  Created by Hao on 2022/4/12.
//

import UIKit
import AVFoundation
import Lottie

class ShareWallViewController: UIViewController {
    
    var videoURL: URL?
    
    var lottieView: AnimationView?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var currentIndex = 0
    
    let viewModel = ShareWallViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBG
        
        navigationItem.hidesBackButton = true
        
        tableView.backgroundColor = .themeBG
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.register(UINib(nibName: "\(ShareWallViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ShareWallViewCell.self)")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredFromBackground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
        setupBind()
        lottieLoading()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        viewModel.fetchData()
//        if let cell = tableView.visibleCells.first as? ShareWallViewCell {
//            cell.play()
//        }
    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = false
//        if let cell = tableView.visibleCells.first as? ShareWallViewCell {
//            cell.pause()
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pausePlayeVideos()
    }
    
    func setupBind() {
        viewModel.shareFilesViewModel.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func lottieLoading() {
        lottieView = .init(name: "Loading")
        lottieView?.frame = view.bounds
        lottieView?.contentMode = .scaleAspectFit
        lottieView?.loopMode = .loop
        tableView.addSubview(lottieView ?? UIView())
        lottieView?.play()
    }
    
    func commentPresent(shareFile: ShareFiles) {
        guard let commentVC = UIStoryboard.shareWall.instantiateViewController(
            withIdentifier: "\(ShareCommentViewController.self)")
                as? ShareCommentViewController
        else {
            return
        }
        commentVC.shareFile = shareFile
        commentVC.modalTransitionStyle = .coverVertical
        commentVC.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(commentVC, animated: true)
    }
    
    private func setButtonAlert(userId: String) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let banAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            UserManager.shared.blockUser(blockId: userId) { result in
                switch result {
                case .success(let text):
                    ProgressHUD.showSuccess(text: "已封鎖")
                    self.dismiss(animated: true)
                    print(text)
                case .failure(let error):
                    print(error)
                    ProgressHUD.showFailure()
                }
            }
        }
        controller.addAction(banAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        // iPad specific code
        controller.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        controller.popoverPresentationController?.sourceRect = popoverRect
        controller.popoverPresentationController?.permittedArrowDirections = .down
        
        present(controller, animated: true, completion: nil)
    }
}

extension ShareWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.shareFilesViewModel.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShareWallViewCell.self)",
            for: indexPath) as? ShareWallViewCell else {
            return UITableViewCell()
        }
        
        lottieView?.removeFromSuperview()
        
        let cellViewModel = self.viewModel.shareFilesViewModel.value[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        cell.isCommentButtonTap = {
            self.commentPresent(shareFile: cellViewModel.shareFile)
        }
        if cellViewModel.shareFile.userId == AuthManager.shared.currentUser {
            cell.setButton.isHidden = true
        } else {
            cell.setButton.isHidden = false
        }
        cell.isSetButtonTap = {
            self.setButtonAlert(userId: cellViewModel.shareFile.userId)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.top
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? AutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
            VideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? ShareWallViewCell {
//            self.currentIndex = indexPath.row
//            cell.play()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? ShareWallViewCell {
//            cell.pause()
//        }
//    }
}

extension ShareWallViewController: UIScrollViewDelegate {

//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let cell = self.tableView.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? ShareWallViewCell
//        cell?.pause()
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let cell = self.tableView.cellForRow(at: IndexPath(row: self.currentIndex, section: 0)) as? ShareWallViewCell
//        cell?.pause()
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    func pausePlayeVideos() {
        VideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    
    @objc func appEnteredFromBackground() {
        VideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }

}
