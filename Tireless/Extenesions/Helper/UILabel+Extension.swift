//
//  UILabel+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/5/6.
//

import Foundation
import UIKit

class UILabelPadding: UILabel {
    
    let padding = UIEdgeInsets(top: 5, left: 5, bottom: 2, right: 5)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
}
