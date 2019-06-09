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
    
    var items: Dictionary<String, Dictionary<String, Any>>? {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversionCompleted(notification:)), name: ConverterService.conversionCompleted, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(notification:)), name: ConverterService.downloadProgress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadCompleted(notification:)), name: ConverterService.downloadCompleted, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        items = ConverterService.sharedInstance.getTasks()
    }
    
    @objc func conversionCompleted(notification: NSNotification) {
        items = ConverterService.sharedInstance.getTasks()
    }
    
    @objc func downloadProgress(notification: NSNotification) {
        var newItems = ConverterService.sharedInstance.getTasks()
        
        guard let taskId = notification.userInfo?["taskId"] as? String,
            let taskProgress = notification.userInfo?["progress"] as? Float else { return }
        
        newItems[taskId]?["progress"] = taskProgress
        
        items = newItems
    }
    
    @objc func downloadCompleted(notification: NSNotification) {
        items = ConverterService.sharedInstance.getTasks()
    }
}

// MARK: - UITableViewDataSource
extension tasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! taskTableViewCell
        
        let key = Array(items!.keys)[indexPath.row]
        let item = items![key]
        let type = item!["type"] as? String
        let title = item!["title"] as? String
        let progress = item!["progress"] as? Float
        
        cell.operationLabel.text = "\(type ?? "Operat")ing:"
        cell.titleLabel.text = title
        cell.progressLabel.text = progress != nil ? "\(Int(progress! * 100))%" : "Please wait"
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension tasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
}
