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
        
        guard let miniPlayerView = self.miniPlayerVC?.view else { return }
        
        miniPlayerView.isHidden = !PlaybackService.sharedInstance.isActive()

        for constraint in self.view.constraints {
            if let layoutGuide = constraint.firstItem as? UILayoutGuide,
                let bottomView = constraint.secondItem as? UIView {
                if PlaybackService.sharedInstance.isActive() {
                    if (constraint.firstAnchor == layoutGuide.bottomAnchor &&
                        bottomView != miniPlayerView) {
                        self.view.removeConstraint(constraint)
                        let constraint1 = miniPlayerView.topAnchor.constraint(equalTo: bottomView.bottomAnchor)
                        let constraint2 = layoutGuide.bottomAnchor.constraint(equalTo: miniPlayerView.bottomAnchor)
                        self.view.addConstraints([constraint1, constraint2])
                    }
                } else {
                    if bottomView == miniPlayerView {
                        if constraint.firstAnchor == layoutGuide.bottomAnchor {
                            self.view.removeConstraint(constraint)
                            for constraint in self.view.constraints {
                                if ((constraint.firstItem as? UIView) == miniPlayerView &&
                                    constraint.firstAttribute == .top) {
                                    if let penultiamteView = constraint.secondItem as? UIView {
                                        self.view.removeConstraint(constraint)
                                        let constraint1 = layoutGuide.bottomAnchor.constraint(equalTo: penultiamteView.bottomAnchor)
                                        self.view.addConstraint(constraint1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        miniPlayerVC?.viewWillAppear(animated)
    }
}
