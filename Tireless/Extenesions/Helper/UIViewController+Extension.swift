//
//  UIViewController+Extension.swift
//  Tireless
//
//  Created by Hao on 2022/5/23.
//

import Foundation
import UIKit

extension UIViewController {

    func presentAlert(withTitle title: String? = nil,
                      message: String? = nil,
                      style: UIAlertController.Style,
                      actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alertController.addAction($0) }
        // For iPad Setting
        alertController.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: self.view.bounds.height, width: 1, height: 1)
        alertController.popoverPresentationController?.sourceRect = popoverRect
        alertController.popoverPresentationController?.permittedArrowDirections = .down
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIAlertAction {
    static let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
}
