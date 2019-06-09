//
//  SearchService.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreData

class ConverterService: NSObject {
    static let sharedInstance = ConverterService()
    static let conversionCompleted = Notification.Name("conversionCompleted")
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadCompleted = Notification.Name("downloadCompleted")
    
    private let host = "https://yerkoh.herokuapp.com"
    private let searchPath = "/search/youtube"
    private let convertPath = "/convert/youtubeToMp3"
    private let downloadPath = "/download/mp3"
    
    private var convertSession: URLSession?
    private var downloadSession: URLSession?
    private var tasks: Dictionary<String, Dictionary<String, Any>> = [:] {
        didSet {
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let tabBarCont = appDelegate.window?.rootViewController as? UITabBarController,
                    let viewControllers = tabBarCont.viewControllers else { return }
                
                for vc in viewControllers {
                    guard let navCont = vc as? UINavigationController,
                        (navCont.topViewController as? tasksViewController != nil) else { continue }
                    
                    navCont.tabBarItem.badgeValue = self.tasks.count > 0 ? "\(self.tasks.count)" : nil
                }
            }
        }
    }
    
    private override init() {
        super.init()
        
        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForRequest = 0
        urlConfig.timeoutIntervalForResource = 0
        convertSession = URLSession(configuration: urlConfig, delegate: self, delegateQueue: nil)
        downloadSession = URLSession(configuration: urlConfig, delegate: self, delegateQueue: nil)
    }
    
    func search(query: String, completionHandler: @escaping (_ result: SearchResponse) -> Void) {
        let urlString = host + searchPath + "?q=" + query
        
        request(urlString: urlString) { data, error in
            guard let data = data else { return }
            do {
                if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let searchResponse = SearchResponse(json: JSON) {
                    completionHandler(searchResponse)
                }
            } catch {}
        }
    }
    
    func convert(id: String, title: String) {
        let urlString = host + convertPath + "?id=" + id
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!
        
        let task = convertSession?.dataTask(with: url)
        tasks["convert_\(task!.taskIdentifier)"] = [
            "id": id,
            "type": "Convert",
            "title": title
        ]
        task?.resume()
    }
    
    func getTasks() -> Dictionary<String, Dictionary<String, Any>> {
        return tasks
    }
    
    private func download(id: String, title: String) {
        let urlString = host + downloadPath + "?id=" + id
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!
        
        let task = downloadSession?.downloadTask(with: url)
        tasks["download_\(task!.taskIdentifier)"] = [
            "id": id,
            "type": "Download",
            "title": title
        ]
        task?.resume()
    }
    
    private func request(urlString: String, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!
        
        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForRequest = 0
        urlConfig.timeoutIntervalForResource = 0
        let session = URLSession(configuration: urlConfig)
        
        let task = session.dataTask(with: url) {(data, response, error) in
            completionHandler(data, error)
        }

        task.resume()
    }
    
    private func save(id: String, title: String, fileData: Data) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Music", in: managedContext)!
            
            let music = NSManagedObject(entity: entity, insertInto: managedContext)
            music.setValue(id, forKeyPath: "id")
            music.setValue(title, forKeyPath: "title")
            music.setValue(fileData, forKeyPath: "file")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print(error)
            }
        }
    }
}

extension ConverterService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if (session == convertSession) {
            let taskId = "convert_\(dataTask.taskIdentifier)"
            
            guard let id = tasks[taskId]?["id"] as? String,
                let title = tasks[taskId]?["title"] as? String else { return }
            
            self.download(id: id, title: title)
            
            tasks.removeValue(forKey: taskId)
            
            NotificationCenter.default.post(name: ConverterService.conversionCompleted, object: nil)
        }
    }
}

extension ConverterService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if (session == downloadSession) {
            let taskId = "download_\(downloadTask.taskIdentifier)"
            
            guard let id = tasks[taskId]?["id"] as? String,
                let title = tasks[taskId]?["title"] as? String else { return }
            
            do {
                let data = try Data(contentsOf: location)
                self.save(id: id, title: title, fileData: data)
            } catch {}
            
            tasks.removeValue(forKey: taskId)
            
            NotificationCenter.default.post(name: ConverterService.downloadCompleted, object: nil)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let taskId = "download_\(downloadTask.taskIdentifier)"
        
        let progressData: [String : Any] = [
            "taskId": taskId,
            "progress": Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        ]
        
        NotificationCenter.default.post(name: ConverterService.downloadProgress, object: nil, userInfo: progressData)
    }
}
