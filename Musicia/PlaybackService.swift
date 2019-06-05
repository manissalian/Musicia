//
//  playbackService.swift
//  Musicia
//
//  Created by Apple on 6/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import AVFoundation

class PlaybackService {
    private init() {}
    static let sharedInstance = PlaybackService()
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFile: Data?
    private var audioTitle: String?
    
    func loadAudio(audioFile: Data, audioTitle: String) {
        self.audioFile = audioFile
        self.audioTitle = audioTitle
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: audioFile)
            audioPlayer!.play()
        } catch {}
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func stop() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            
            audioPlayer?.stop()
            audioPlayer = nil
            
            audioFile = nil
            audioTitle = nil
        } catch {}
    }
    
    func replay() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    func getAudioTitle() -> String? {
        return audioTitle
    }
    
    func getCurrentTime() -> Double? {
        return audioPlayer?.currentTime
    }
    
    func getDuration() -> Double? {
        return audioPlayer?.duration
    }
    
    func getVolume() -> Float? {
        return audioPlayer?.volume
    }
    
    func setCurrentTime(time: Float) {
        audioPlayer?.currentTime = (audioPlayer?.duration ?? 0) * Double(time)
    }
    
    func setVolume(volume: Float) {
        audioPlayer?.volume = volume
    }
    
    func isActive() -> Bool {
        return audioPlayer != nil
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
}
