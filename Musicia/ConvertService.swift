//
//  SearchService.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ConvertService: NSObject {
    static let sharedInstance = ConvertService()
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadCompleted = Notification.Name("downloadCompleted")

    private let streamPath = "/convert/youtubeToMp3/stream"
    private let progressPath = "/convert/progress"

    private var streamSession: URLSession?
    private var progressSession: URLSession?
    
    private var conversionId = 0
    private var deviceId = UIDevice.current.identifierForVendor?.uuidString

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
        
        let progressConfig = makeConfig(sessionId: "com.apple.Musicia.bg.progress")
        progressSession = URLSession(configuration: progressConfig, delegate: self, delegateQueue: nil)
    }
    
    func stream(id: String, title: String) {
        conversionId += 1
        let urlString = host + streamPath + "?id=" + id + "&conversionId=" + deviceId! + "\(conversionId)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        
        guard let streamSession = streamSession else { return }

        let task = streamSession.dataTask(with: url)
        let taskId = getFullTaskId(streamSession, task)
        let streamTask = StreamTask(id: taskId, videoId: id, title: title)
        tasks.append(streamTask)
        task.resume()
        
        attachProgressTask(id: id, title: title, streamTask: streamTask)
    }
    
    func attachProgressTask(id: String, title: String, streamTask: StreamTask) {
        let urlString = host + progressPath + "?conversionId=" + deviceId! + "\(conversionId)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!

        guard let progressSession = progressSession else { return }

        let task = progressSession.dataTask(with: url)
        let taskId = getFullTaskId(progressSession, task)
        streamTask.progressTaskId = taskId
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

extension ConvertService: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let taskId = getFullTaskId(session, dataTask)

        if (session == streamSession) {
            guard let streamTask = tasks.first(where: { $0.id == taskId }) else { return }

            if (streamTask.data == nil) {
                streamTask.data = data
            } else {
                streamTask.data!.append(data)
            }
        } else if (session == progressSession) {
            guard let streamTask = tasks.first(where: { $0.progressTaskId == taskId }) else { return }

            do {
                if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let streamProgressResponse = StreamProgressResponse(json: JSON) {
                        streamTask.progress = streamProgressResponse.progress

                        NotificationCenter.default.post(name: ConvertService.downloadProgress, object: nil)
                    } else if let streamProgressResponse = StreamSuccessResponse(json: JSON),
                        let data = streamTask.data,
                        streamProgressResponse.success {
                        CoreDataInterface().saveMusic(id: streamTask.videoId, title: streamTask.title, fileData: data)

                        tasks = tasks.filter { $0.id != streamTask.id }

                        NotificationCenter.default.post(name: ConvertService.downloadCompleted, object: nil)

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
                    }
                }
            } catch {}
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

extension ConvertService: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
}
