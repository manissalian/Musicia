//
//  utils.swift
//  Musicia
//
//  Created by Apple on 5/31/19.
//  Copyright © 2019 Apple. All rights reserved.
//

func secondsToTime (seconds : Int) -> String {
    let hours = String(format: "%02d", seconds / 3600)
    let minutes = String(format: "%02d", (seconds % 3600) / 60)
    let seconds = String(format: "%02d", (seconds % 3600) % 60)
    
    return "\(hours):\(minutes):\(seconds)"
}
