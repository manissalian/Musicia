//
//  ErrorManager.swift
//  Musicia
//
//  Created by Apple on 2/2/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ErrorManager: NSObject {
    static let sharedInstance = ErrorManager()
    static let errorNotification = Notification.Name("error")

    private override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(handleError(notification:)), name: ErrorManager.errorNotification, object: nil)
    }

    @objc func handleError(notification: NSNotification) {
        guard let title = notification.userInfo?["title"] as? String,
            let message = notification.userInfo?["message"] as? String else { return }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))

        presentError(alertController: alert)
    }
    
    func presentError(alertController: UIAlertController) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let tabBarCont = appDelegate.window?.rootViewController as? UITabBarController,
            let selectedNavVC = tabBarCont.selectedViewController as? UINavigationController,
            let selectedVC = selectedNavVC.topViewController else { return }

        DispatchQueue.main.async {
            selectedVC.present(alertController, animated: true)
        }
    }
}
