//
//  Models.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

struct SearchItem {
    var id: String
    var title: String
    var thumbnailUrl: String
    var duration: Int
}

extension SearchItem: Codable {
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
