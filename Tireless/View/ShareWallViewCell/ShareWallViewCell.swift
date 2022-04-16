//
//  ShareWallViewCell.swift
//  Tireless
//
//  Created by Hao on 2022/4/14.
//

import Foundation
import UIKit

class ShareWallViewCell: UITableViewCell {
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoTitleText: UILabel!
    
    @IBOutlet weak var videoContentText: UILabel!
    
    var viewModel: VideoViewModel?
    
    func setup(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        layoutCell()
    }
    
    func layoutCell() {
        videoTitleText.text = viewModel?.video.videoName
        videoContentText.text = Date.dateFormatter.string(from:
                                                            Date.init(milliseconds: viewModel?.video.createdTime ?? 0))
    }
}
