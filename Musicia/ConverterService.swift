//
//  SearchService.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ConverterService: NSObject {
    static let sharedInstance = ConverterService()
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadCompleted = Notification.Name("downloadCompleted")

    private let host = "https://yerkoh.herokuapp.com"
    private let searchPath = "/search/youtube"
    private let streamPath = "/convert/youtubeToMp3/stream"

    private var streamSession: URLSession?

    private(set) var tasks: [StreamTask] = [] {
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

    // todo: convert to array
    var savedCompletionHandler: (() -> Void)?

    private override init() {
        super.init()

        let streamConfig = makeConfig(sessionId: "com.apple.Musicia.bg.stream")
        streamSession = URLSession(configuration: streamConfig, delegate: self, delegateQueue: nil)
    }

    func search(query: String, completionHandler: @escaping (_ result: SearchResponse) -> Void) {
        let urlString = host + searchPath + "?q=" + query

        request(urlString: urlString) { data, error in
            guard let data = data else {
                NotificationCenter.default.post(name: ErrorManager.errorNotification, object: nil, userInfo: [
                    "title": "Search Error",
                    "message": "An error occured while searching for \(query)"
                ])

                return
            }
            do {
                if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let searchResponse = SearchResponse(json: JSON) {
                    completionHandler(searchResponse)
                }
            } catch {}
        }
    }
    
    func stream(id: String, title: String) {
        let urlString = host + streamPath + "?id=" + id
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!
        
        guard let streamSession = streamSession else { return }

        let task = streamSession.dataTask(with: url)
        let taskId = getFullTaskId(streamSession, task)
        let streamTask = StreamTask(id: taskId, videoId: id, title: title)
        tasks.append(streamTask)
        task.resume()
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
    
    private func makeConfig(sessionId: String) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: sessionId)
        config.timeoutIntervalForRequest = 0
        config.timeoutIntervalForResource = 0
        
        return config
    }
    
    private func getFullTaskId (_ session: URLSession, _ task: URLSessionTask) -> String {
        guard let sessionId = session.configuration.identifier else { return "" }
        let taskId = task.taskIdentifier
        
        return "\(sessionId)_\(taskId)"
    }
}

extension ConverterService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let taskId = getFullTaskId(session, dataTask)
        guard let streamTask = tasks.first(where: { $0.id == taskId }) else { return }

        do {
            if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let streamProgressResponse = StreamProgressResponse(json: JSON) {

                streamTask.progress = streamProgressResponse.progress
                NotificationCenter.default.post(name: ConverterService.downloadProgress, object: nil)

                return
            }
        } catch {}

        do {
            if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let streamProgressResponse = StreamSuccessResponse(json: JSON),
                let data = streamTask.data,
                streamProgressResponse.success {
                if (session == streamSession) {
                    CoreDataInterface().saveMusic(id: streamTask.videoId, title: streamTask.title, fileData: data)
                }

                tasks = tasks.filter { $0.id != streamTask.id }
                NotificationCenter.default.post(name: ConverterService.downloadCompleted, object: nil)
                
                let alertController = UIAlertController(
                    title: "Download Success",
                    message: "\(streamTask.title) downloaded successfully!",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))

                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                        let tabBarCont = appDelegate.window?.rootViewController as? UITabBarController,
                        let selectedNavVC = tabBarCont.selectedViewController as? UINavigationController,
                        let selectedVC = selectedNavVC.topViewController else { return }

                    selectedVC.present(alertController, animated: true)
                }

                return
            }
        } catch {}

        if (streamTask.data == nil) {
            streamTask.data = data
        } else {
            streamTask.data!.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let httpResponse = task.response as? HTTPURLResponse else { return }

        let taskId = getFullTaskId(session, task)

        if (httpResponse.statusCode >= 400) {
            guard let streamTask = tasks.first(where: { $0.id == taskId }) else { return }

            if (session == streamSession) {
                NotificationCenter.default.post(name: ErrorManager.errorNotification, object: nil, userInfo: [
                    "title": "Save Audio Error",
                    "message": "An error occured while saving \(streamTask.title)"
                ])
            }

            tasks = tasks.filter { $0.id != streamTask.id }
        }
    }
}

extension ConverterService: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
}
