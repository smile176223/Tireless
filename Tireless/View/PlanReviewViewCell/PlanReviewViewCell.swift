//
//  PlanReviewViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/5/5.
//

import UIKit
import AVFoundation

class PlanReviewViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var planTimeLabel: UILabel!
    
    @IBOutlet weak var finishTimeLabel: UILabel!
    
    var isPlayButtonTap: (() -> Void)?
    
    var viewModel: FinishTimeViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    func setup(viewModel: FinishTimeViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    private func layoutCell() {
        guard let viewModel = viewModel else {
            return
        }
        dayLabel.text = "\(viewModel.finishTime.day)"
        planTimeLabel.text = "\(viewModel.finishTime.planTimes)次/秒"
        let finishDate = Date(milliseconds: viewModel.finishTime.time)
        finishTimeLabel.text = "完成時間: \(Date.dateFormatter.string(from: finishDate))"
        if viewModel.finishTime.videoId == "" {
            thumbnailImageView.image = UIImage.placeHolder
        }
        if let url = URL(string: viewModel.finishTime.videoURL ?? "") {
            DispatchQueue.main.async {
                self.thumbnailImageView.image = self.generateThumbnail(path: url)
            }
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func setupLayout() {
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.backgroundColor = .themeBGSecond
    }

    @IBAction func playButtonTap(_ sender: UIButton) {
        isPlayButtonTap?()
    }
}
