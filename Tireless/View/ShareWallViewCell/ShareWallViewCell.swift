//
//  ShareWallViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation
import UIKit
import AVFoundation
import Lottie

class ShareWallViewCell: UITableViewCell, AutoPlayVideoLayerContainer {
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoTitleText: UILabel!
    
    @IBOutlet weak var videoContentText: UILabel!
    
    @IBOutlet weak var setButton: CustomButton!
    
    @IBOutlet weak var videoUserImageVeiw: UIImageView!
    
    var viewModel: ShareFilesViewModel?
    
    var isCommentButtonTap: (() -> Void)?
    
    var isSetButtonTap: (() -> Void)?
    
    var playerController: VideoPlayerController?
    
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
    var lottieView: AnimationView?
    
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                VideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.addSublayer(videoLayer)
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = videoView.bounds
    }

    func setup(viewModel: ShareFilesViewModel) {
        self.viewModel = viewModel
        configureCell(videoUrl: viewModel.shareFile.shareURL)
        layoutCell()
        setupLayout()
        setupLabel(videoTitleText)
        setupLabel(videoContentText)
    }
    
    func configureCell(videoUrl: URL) {
        self.videoURL = videoUrl.absoluteString
    }
    
    func layoutCell() {
        videoTitleText.text = viewModel?.shareFile.user?.name
        let date = Date.dateFormatter.string(
            from: Date.init(milliseconds: viewModel?.shareFile.createdTime ?? 0))
        videoContentText.text = "\(viewModel?.shareFile.content ?? "")\n\(date)"
        if viewModel?.shareFile.user?.picture != "" {
            videoUserImageVeiw.loadImage(viewModel?.shareFile.user?.picture)
        }
    }
    
    func setupLayout() {
        setButton.touchEdgeInsets = UIEdgeInsets(top: -15, left: -10, bottom: -15, right: -10)
        videoUserImageVeiw.layer.cornerRadius = videoUserImageVeiw.frame.height / 2
    }
    
    private func setupLabel(_ label: UILabel) {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
    }
    
    @IBAction func commentButtonTap(_ sender: UIButton) {
        isCommentButtonTap?()
    }
    @IBAction func setButtonTqp(_ sender: UIButton) {
        isSetButtonTap?()
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(videoView.frame, from: videoView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    
}
