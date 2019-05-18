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
    
    private let searchUrl = "http://192.168.1.76:3000/search/youtube"
    
    func search(query: String, completionHandler: @escaping (_ result: SearchResponse) -> Void) {
        let url = URL(string: searchUrl + "?q=" + query)!
        
        request(url: url) { data, error in
            guard let data = data else { return }
            do {
                if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let searchResponse = SearchResponse(json: JSON) {
                    completionHandler(searchResponse)
                }
            } catch {}
        }
    }
    
    private func request(url: URL, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            completionHandler(data, error)
        }
        
        task.resume()
    }
}
