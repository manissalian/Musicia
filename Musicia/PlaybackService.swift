//
//  playbackService.swift
//  Musicia
//
//  Created by Apple on 6/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class PlaybackService: NSObject {
    static let sharedInstance = PlaybackService()
    
    private var audioPlayer: AVAudioPlayer?
    private var audioFile: Data?
    private var audioTitle: String?
    
    private override init() {
        super.init()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            PlaylistManager.sharedInstance.jumpToNext()
            self.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            PlaylistManager.sharedInstance.jumpToPrevious()
            self.updateNowPlayingInfo()
            return .success
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
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
        audioPlayer?.pause()
        
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
    
    @objc private func didEnterBackground(notification: NSNotification) {
        updateNowPlayingInfo()
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioTitle
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
