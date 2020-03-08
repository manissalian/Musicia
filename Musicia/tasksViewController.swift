//
//  tasksViewController.swift
//  Musicia
//
//  Created by Apple on 6/8/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class tasksViewController: baseViewController {
    @IBOutlet weak var tableView: UITableView!
    var items: [StreamTask] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "taskTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "taskCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(notification:)), name: ConverterService.downloadProgress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadCompleted(notification:)), name: ConverterService.downloadCompleted, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        items = ConverterService.sharedInstance.tasks
    }
    
    @objc func conversionCompleted(notification: NSNotification) {
        items = ConverterService.sharedInstance.tasks
    }
    
    @objc func downloadProgress(notification: NSNotification) {
        items = ConverterService.sharedInstance.tasks
    }
    
    @objc func downloadCompleted(notification: NSNotification) {
        items = ConverterService.sharedInstance.tasks
    }
}

// MARK: - UITableViewDataSource
extension tasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! taskTableViewCell
        
        if (indexPath.row >= items.count) {
            return cell
        }

        let item = items[indexPath.row]

        cell.operationLabel.text = "Downloading"
        cell.titleLabel.text = item.title
        cell.progressLabel.text = item.progress
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension tasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
}
