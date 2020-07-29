//
//  PreviewVideoViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 28/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PreviewVideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playPressed(_ sender: UIButton) {
        if isVideoPlaying {
            player?.pause()
            let playSymbol = UIImage(systemName: "play")
            sender.setImage(playSymbol, for: .normal)
        }else {
            player?.play()
            let pauseSymbol = UIImage(systemName: "pause")
            sender.setImage(pauseSymbol, for: .normal)
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player?.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
    var url: URL?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var isVideoPlaying = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(addTappedPost))
        self.playerController = AVPlayerViewController()
        self.playVideo()
    }
    
    @objc func addTappedPost(sender: UIBarButtonItem) {
        if let url = self.url {
            let storyboard = UIStoryboard(name: "NewPostForm", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewPostFormViewController") as! NewPostFormViewController
            let post = Post(title: "", viewer: 0, lpm: 0, videoUrl: url, isSensitiveContent: false, isLive: false)
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func playVideo() {
        if let url = self.url, let playerController = playerController {
            
            player = AVPlayer(url: url)
            addTimeObserver()
            
            playerController.showsPlaybackControls = false
            playerController.player = player
            self.addChild(playerController)
            self.videoView.addSubview(playerController.view)
            playerController.view.frame = videoView.frame
            playerController.videoGravity = AVLayerVideoGravity.resizeAspect
            
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
                } else {
                }
            } catch let error as NSError {
                print(error)
            }
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player?.currentItem else {return}
            
            self?.timeSlider.maximumValue = 1
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.duration.seconds / currentItem.currentTime().seconds)
            
            self?.leftTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }

}
