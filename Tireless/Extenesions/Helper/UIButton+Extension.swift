//
//  UIButton+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/5/6.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    var touchEdgeInsets: UIEdgeInsets?
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var frame = self.bounds
        if let touchEdgeInsets = self.touchEdgeInsets {
            frame = frame.inset(by: touchEdgeInsets)
        }
        return frame.contains(point)
    }
}
