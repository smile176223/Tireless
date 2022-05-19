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
    
    var recordStatus: RecordStatus = .userAgree

    init(plan: Plan) {
        self.plan = plan
    }
    
}
