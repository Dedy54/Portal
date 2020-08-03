//
//  VideoPlayerStatsViewController.swift
//  Portal
//
//  Created by Azam Mukhtar on 02/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AVKit
import CloudKit

class VideoPlayerStatsViewController: UIViewController {
    @IBOutlet weak var labelNama: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelViewer: UILabel!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var swipeForDetail: UILabel!
    
    var post : Post?
    var player : AVPlayer?
    
    var timer : Timer?
    var duration : Double?
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.viewTapped(gestureRecognizer:)))
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        swipeUp.addTarget(self, action: #selector(VideoPlayerStatsViewController.swipedViewUp(swipeUp:)))
             view.addGestureRecognizer(swipeUp)
        playVideo()
    }
    
//    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
//          view.endEditing(true)
//      }
    @objc func swipedViewUp(swipeUp : UISwipeGestureRecognizer){

        performSegue(withIdentifier: "toStatsDetail", sender: post)
        print("Swiped Up")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? DetailStatsViewController {
                destination.post = sender as? Post
            }
        }
    func playVideo(){
        let videoData = NSData(contentsOf: (post?.video?.fileURL)!)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent("filename.mov", isDirectory: false)

        FileManager.default.createFile(atPath: destinationPath!.path, contents:videoData as Data?, attributes:nil)

        let asset = AVURLAsset(url: destinationPath!)
            let durationInSeconds = asset.duration.seconds
            print(durationInSeconds)
            duration = durationInSeconds
            

        player = AVPlayer(url: destinationPath!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame =  self.view.bounds
        //        playerLayer.addSublayer(asd.layer)
        playerLayer.addSublayer(imagePhoto.layer)
        playerLayer.addSublayer(swipeForDetail.layer)
        playerLayer.addSublayer(buttonView.layer)
        playerLayer.addSublayer(labelTime.layer)
        playerLayer.addSublayer(labelNama.layer)
        playerLayer.addSublayer(labelViewer.layer)
        self.view.layer.addSublayer(playerLayer)
        player?.play()
        
       setLabelTime()
        
    }
    func setLabelTime(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                      self.time = self.time + 1
            
            if self.time < Int(self.duration!) {
                let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: self.time)
                               self.labelTime.text = "\(h):\(m):\(s)"
                                 }
            }
               
        labelViewer.text = "\(post?.viewer ?? 0)"
        labelNama.text = PreferenceManager.instance.userName
    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
           return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewDidDisappear(_ animated: Bool) {
        player?.pause()
    }
}
