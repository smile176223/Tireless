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
    
    @IBOutlet private weak var videoView: UIView!
    
    @IBOutlet private weak var videoTitleText: UILabel!
    
    @IBOutlet private weak var videoContentText: UILabel!
    
    @IBOutlet private weak var setButton: CustomButton!
    
    @IBOutlet private weak var commentButton: UIButton!
    
    @IBOutlet private weak var videoUserImageVeiw: UIImageView!
    
    private var viewModel: ShareFilesViewModel?
    
    var commentButtonTapped: (() -> Void)?
    
    var setButtonTapped: (() -> Void)?
    
    var playerController: VideoPlayerController?
    
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
    var lottieView: LottieAnimationView?
    
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
        setButton.isHidden = false
        commentButton.isHidden = false
        videoUserImageVeiw.isHidden = false
    }
    
    func setupEmpty() {
        self.videoURL = nil
        setButton.isHidden = true
        commentButton.isHidden = true
        videoTitleText.text = ""
        videoUserImageVeiw.isHidden = true
        videoContentText.text = ""
    }
    
    func configureCell(videoUrl: URL) {
        self.videoURL = videoUrl.absoluteString
    }
    
    private func layoutCell() {
        videoTitleText.text = viewModel?.shareFile.user?.name
        let date = Date.dateFormatter.string(
            from: Date.init(milliseconds: viewModel?.shareFile.createdTime ?? 0))
        videoContentText.text = "\(viewModel?.shareFile.content ?? "")\n\(date)"
        if viewModel?.shareFile.user?.picture != "" {
            videoUserImageVeiw.loadImage(viewModel?.shareFile.user?.picture)
        } else {
            videoUserImageVeiw.image = UIImage.placeHolder
        }
    }
    
    private func setupLayout() {
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
        commentButtonTapped?()
    }
    @IBAction func setButtonTqp(_ sender: UIButton) {
        setButtonTapped?()
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
