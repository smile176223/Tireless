//
//  WebkitViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/9.
//

import UIKit
import WebKit

class WebkitViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    var viewModel: WebkitViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
    }
    
    private func loadURL() {
        guard let viewModel = viewModel,
              let url = URL(string: viewModel.urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
}
