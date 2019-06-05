//
//  baseViewController.swift
//  Musicia
//
//  Created by Apple on 6/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class baseViewController: UIViewController {
    var miniPlayerVC: miniPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniPlayerVC = miniPlayerViewController()
        miniPlayerVC!.view.frame.origin = CGPoint(x: 0, y: view.frame.size.height - miniPlayerVC!.view.frame.size.height - (tabBarController?.tabBar.frame.size.height ?? 0))
        miniPlayerVC!.parentVC = self
        view.addSubview(miniPlayerVC!.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        miniPlayerVC?.view.isHidden = !PlaybackService.sharedInstance.isActive()
        
        miniPlayerVC?.viewWillAppear(animated)
    }
}
