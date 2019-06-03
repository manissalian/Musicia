//
//  SearchService.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ConverterService {
    private init() {}
    static let sharedInstance = ConverterService()
    
    private let host = "http://192.168.104.36:3000"
    private let searchPath = "/search/youtube"
    private let convertPath = "/convert/youtubeToMp3"
    private let downloadPath = "/download/mp3"
    
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
    
    func convert(id: String, completionHandler: @escaping (_ result: String) -> Void) {
        let urlString = host + convertPath + "?id=" + id
        
        request(urlString: urlString) { data, error in
            guard let data = data,
                let res = String(data: data, encoding: String.Encoding.utf8) else { return }
            
            completionHandler(res)
        }
    }
    
    func download(id: String, completionHandler: @escaping (_ result: Data) -> Void) {
        let urlString = host + downloadPath + "?id=" + id
        
        request(urlString: urlString) { data, error in
            guard let data = data else { return }
            
            completionHandler(data)
        }
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
}
