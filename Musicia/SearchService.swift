//
//  SearchService.swift
//  Musicia
//
//  Created by Apple on 3/15/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

class SearchService: NSObject {
    static let sharedInstance = SearchService()

    private let searchPath = "/search/youtube"

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
}
