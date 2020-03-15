//
//  Search.swift
//  Musicia
//
//  Created by Apple on 3/15/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

struct SearchItem: Codable {
    var id: String
    var title: String
    var thumbnailUrl: String
    var duration: Int
    
    init(dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(SearchItem.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}

struct SearchResponse {
    var items: Array<Any>
    
    init?(json: [String: Any]) {
        guard let items = json["items"] as? Array<Any> else {
            return nil
        }
        self.items = items
    }
}
