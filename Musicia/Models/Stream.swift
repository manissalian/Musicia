//
//  Models.swift
//  Musicia
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class StreamTask {
    var id: String
    var videoId: String
    var title: String
    var data: Data?
    var progress: String = "0%"
    var progressTaskId: String?
    
    init (id: String, videoId: String, title: String) {
        self.id = id
        self.videoId = videoId
        self.title = title
    }
}

struct StreamProgressResponse {
    var progress: String
    
    init?(json: [String: Any]) {
        guard let progress = json["progress"] as? String else {
            return nil
        }
        self.progress = progress
    }
}

struct StreamSuccessResponse {
    var success: Bool
    
    init?(json: [String: Any]) {
        guard let success = json["success"] as? Bool else {
            return nil
        }
        self.success = success
    }
}
