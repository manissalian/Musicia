//
//  utils.swift
//  Musicia
//
//  Created by Apple on 5/31/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

func secondsToTime (seconds : Int) -> String {
    let hours = String(format: "%02d", seconds / 3600)
    let minutes = String(format: "%02d", (seconds % 3600) / 60)
    let seconds = String(format: "%02d", (seconds % 3600) % 60)
    
    return "\(hours):\(minutes):\(seconds)"
}

extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)
    }
}
