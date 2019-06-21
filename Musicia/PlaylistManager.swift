//
//  PlaybackManager.swift
//  Musicia
//
//  Created by Apple on 6/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

class PlaylistManager: NSObject {
    static let sharedInstance = PlaylistManager()
    
    private var items: [String]?
    private var activeItemIndex: Int?
    
    func loadPlaylist(items: [String], activeItemIndex index: Int) {
        self.items = items
        self.activeItemIndex = index
        
        playItemAtIndex(index: activeItemIndex!)
    }
    
    func jumpToNext() {
        if activeItemIndex == nil || items == nil { return }
        
        activeItemIndex = activeItemIndex! < items!.count - 1 ? activeItemIndex! + 1 : 0
        
        playItemAtIndex(index: activeItemIndex!)
    }
    
    func jumpToPrevious() {
        if activeItemIndex == nil || items == nil { return }
        
        activeItemIndex = activeItemIndex! > 0 ? activeItemIndex! - 1 : items!.count - 1
        
        playItemAtIndex(index: activeItemIndex!)
    }
    
    private func playItemAtIndex(index: Int) {
        let music = CoreDataInterface().getMusicById(id: items![index])
        
        guard let audioFile = music?.file,
            let audioTitle = music?.title else { return }
        
        PlaybackService.sharedInstance.loadAudio(audioFile: audioFile, audioTitle: audioTitle)
    }
}
