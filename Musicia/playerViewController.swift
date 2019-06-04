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
    
    var audioPlayer: AVAudioPlayer!
    var audioFile: Data!
    var audioTitle: String!
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
        
        titleLabel.text = audioTitle
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(data: audioFile)
            audioPlayer.play()
            
            durationLabel.text = secondsToTime(seconds: Int(audioPlayer.duration))
            
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        } catch {}
    }
    
    @objc func updateCurrentTime() {
        currentTimeLabel.text = secondsToTime(seconds: Int(audioPlayer.currentTime))
        
        progressSlider.value = Float(audioPlayer.currentTime / audioPlayer.duration)
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        audioPlayer.play()
        pause = false
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        audioPlayer.pause()
        pause = true
    }
    
    @IBAction func stopBtnPressed(_ sender: Any) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            
            audioPlayer.stop()
            audioPlayer = nil
            
            audioFile = nil
            audioTitle = nil
            
            timer?.invalidate()
            timer = nil
            
            self.dismiss(animated: true, completion: nil)
        } catch {}
    }
    
    @IBAction func replayBtnPressed(_ sender: Any) {
        audioPlayer.currentTime = 0
        audioPlayer.play()
        pause = false
    }
    
    @IBAction func progressSliderDraggedInside(_ sender: Any) {
        audioPlayer.pause()
        pause = true
        
        audioPlayer.currentTime = audioPlayer.duration * Double(progressSlider.value)
    }
    
    @IBAction func progressSliderTouchedUpInside(_ sender: Any) {
        audioPlayer.play()
        pause = false
    }
    
    @IBAction func volumeOffBtnPressed(_ sender: Any) {
        audioPlayer.volume = volumeSlider.value
        mute = false
    }
    
    @IBAction func volumeOnBtnPressed(_ sender: Any) {
        audioPlayer.volume = 0
        mute = true
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
        if mute { return }
        
        audioPlayer.volume = volumeSlider.value
    }
}
