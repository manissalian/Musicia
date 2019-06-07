//
//  previewViewController.swift
//  Musicia
//
//  Created by Apple on 6/7/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class previewViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadRequest(URLRequest(url: URL(string: "https://www.youtube.com/watch?v=\(id ?? "")")!))
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        webView = nil
        id = nil
        
        self.dismiss(animated: true)
    }
}
