//
//  playerViewController.swift
//  Musicia
//
//  Created by Apple on 6/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AVFoundation

class playerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var volumeOffBtn: UIButton!
    @IBOutlet weak var volumeOnBtn: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var timer: Timer?
    
    var pause = false {
        didSet {
            pauseBtn.isHidden = pause
            playBtn.isHidden = !pause
        }
    }
    var mute = false {
        didSet {
            volumeOnBtn.isHidden = mute
            volumeOffBtn.isHidden = !mute
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        durationLabel.text = secondsToTime(seconds: Int(PlaybackService.sharedInstance.getDuration() ?? 0))
        
        pause = !PlaybackService.sharedInstance.isPlaying()
        
        volumeSlider.value = PlaybackService.sharedInstance.getVolume() ?? volumeSlider.value

        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer?.invalidate()
        timer = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateCurrentTime() {
        guard let currentTime = PlaybackService.sharedInstance.getCurrentTime(),
            let duration = PlaybackService.sharedInstance.getDuration() else { return }
        
        currentTimeLabel.text = secondsToTime(seconds: Int(currentTime))

        progressSlider.value = Float(currentTime / duration)
    }
    
    @objc private func didBecomeActive(notification: NSNotification) {
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        durationLabel.text = secondsToTime(seconds: Int(PlaybackService.sharedInstance.getDuration() ?? 0))
        
        pause = !PlaybackService.sharedInstance.isPlaying()
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.play()
        pause = false
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.pause()
        pause = true
    }
    
    @IBAction func stopBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.stop()
        
        self.dismiss(animated: true)
    }
    
    @IBAction func replayBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.replay()
        pause = false
    }
    
    @IBAction func progressSliderDraggedInside(_ sender: Any) {
        PlaybackService.sharedInstance.pause()
        pause = true
        
        PlaybackService.sharedInstance.setCurrentTime(time: progressSlider.value)
    }
    
    @IBAction func progressSliderTouchedUpInside(_ sender: Any) {
        PlaybackService.sharedInstance.play()
        pause = false
    }
    
    @IBAction func volumeOffBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.setVolume(volume: volumeSlider.value)
        mute = false
    }
    
    @IBAction func volumeOnBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.setVolume(volume: 0)
        mute = true
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
        if mute { return }
        
        PlaybackService.sharedInstance.setVolume(volume: volumeSlider.value)
    }
    
    @IBAction func minimizeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func previousBtnPressed(_ sender: Any) {
        PlaylistManager.sharedInstance.jumpToPrevious()
        
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        durationLabel.text = secondsToTime(seconds: Int(PlaybackService.sharedInstance.getDuration() ?? 0))
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        PlaylistManager.sharedInstance.jumpToNext()
        
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        durationLabel.text = secondsToTime(seconds: Int(PlaybackService.sharedInstance.getDuration() ?? 0))
    }
}
