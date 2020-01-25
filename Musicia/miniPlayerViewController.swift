//
//  miniPlayerViewController.swift
//  Musicia
//
//  Created by Apple on 6/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class miniPlayerViewController: UIViewController {
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var parentVC: UIViewController?
    
    var pause = false {
        didSet {
            pauseBtn.isHidden = pause
            playBtn.isHidden = !pause
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        pause = !PlaybackService.sharedInstance.isPlaying()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(viewTapped))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        pause = !PlaybackService.sharedInstance.isPlaying()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.pause()
        pause = true
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        PlaybackService.sharedInstance.play()
        pause = false
    }
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyBoard.instantiateViewController(withIdentifier: "player") as! playerViewController
        
        parentVC?.present(playerVC, animated: true)
    }
    
    @objc private func didBecomeActive(notification: NSNotification) {
        titleLabel.text = PlaybackService.sharedInstance.getAudioTitle()
        
        pause = !PlaybackService.sharedInstance.isPlaying()
    }
}
