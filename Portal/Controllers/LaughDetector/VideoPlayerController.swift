//
//  LaughClassifier.swift
//  Portal
//
//  Created by Azam Mukhtar on 24/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import AVKit
import SoundAnalysis
import CloudKit

class VideoPlayerController: UIViewController, LaughClassifierDelegate {
    //    let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    var player : AVPlayer?
    
    @IBOutlet weak var imageVideoPlayerProfile: UIImageView!
    
    @IBOutlet weak var labelVideoPlayerUserName: UILabel!
    
    @IBOutlet weak var labelVideoPlayerViewersCount: UILabel!
    @IBOutlet weak var buttonVideoPlayerMuteUnMuteMic: UIButton!
    @IBOutlet weak var buttonVideoPlayerCount: UIButton!
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = LaughClassifier()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    var laughList : [Laugh] = []
    
    var post : Post?
    
    var duration : Double?
    
    var timer : Timer?
    
    var time = 0
    
    var totalKetawa : Double?
    var totalViewer : Int?
    
    var postIdCKRecord : CKRecord.ID?
    
    var isMute = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch (_) {
            print("error in starting the Audio AVAudioSession")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        totalKetawa = post?.lpm
        totalViewer = post?.viewer
        postIdCKRecord = post?.id
        hideNavigationBar()
        playVideo()
        setData()
        viewersCount()
        
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }
    
    
    @IBAction func muteUnMute(_ sender: Any) {
        if isMute == false {
            isMute = true
            audioEngine.pause()
            if let image = UIImage(named: "icon_mic_mute.png") {
                buttonVideoPlayerMuteUnMuteMic.setImage(image, for: .normal)
            }
        } else if isMute == true {
            isMute = false
            do{
                try audioEngine.start()
            }catch( _){
                print("error in starting the Audio Engine")
            }
            if let image = UIImage(named: "icon_mic.png") {
                buttonVideoPlayerMuteUnMuteMic.setImage(image, for: .normal)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAudioEngine()
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -280 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
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
        playerLayer.addSublayer(imageVideoPlayerProfile.layer)
        playerLayer.addSublayer(labelVideoPlayerViewersCount.layer)
        playerLayer.addSublayer(labelVideoPlayerUserName.layer)
        playerLayer.addSublayer(buttonVideoPlayerMuteUnMuteMic.layer)
        playerLayer.addSublayer(buttonVideoPlayerCount.layer)
        self.view.layer.addSublayer(playerLayer)
        player?.play()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.time = self.time + 1
        }
        
    }
    func viewersCount(){
        totalViewer = totalViewer! + 1
        
        labelVideoPlayerViewersCount.text = "\(totalViewer ?? 0)"

        let database = CloudKitService.shared.container.publicCloudDatabase
        database.fetch(withRecordID:  (post?.id!)!) { (result, error) in
            if error != nil {
                print(error!)
            } else {
                if result != nil {
                    result?.setValue(self.totalViewer, forKey: "viewer")
                    database.save(result!) { (result, error) in
                        if error != nil {
                            print(error!)
                             print("error viewer")
                        } else {
                            if result != nil {
                                print(result!)
                                print("Success viewer")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    func setData(){
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(PreferenceManager.instance.userEmail ?? "")" ])
        User.query(predicate: predicate, result: { (users) in
            DispatchQueue.main.async {
                self.labelVideoPlayerUserName.text = users?.first?.name
            }
        }) { (error) in
            print(error)
        }
    }
    
    func stopVideo(){
        player?.pause()
    }
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func displayPredictionResult(identifier: String, confidence: Double) {
        if identifier == "laugh"{
            updateLaughToCloudKit(laugh: Laugh(postId: "\(post!.id!)", isLaugh: 1, second: time, totalDuration: duration))
//            print(laughList[0].postId!)
            totalKetawa = totalKetawa! + 1
            DispatchQueue.main.async {
                self.generateAnimatedViews()
            }
        }
    }
    
    func updateLaughToCloudKit(laugh : Laugh){
        laugh.save(result: { (laugh) in
            print("suecess tawa")
        }) { (error) in
            print(error!)
            print("error tawa")
        }
    }
    
    func updateLaughToCloudKit(){
        let database = CloudKitService.shared.container.publicCloudDatabase
        database.fetch(withRecordID:  (post?.id!)!) { (result, error) in
            if error != nil {
                print(error!)
            } else {
                if result != nil {
                    result?.setValue(self.totalKetawa, forKey: "lpm")
                    database.save(result!) { (result, error) in
                        if error != nil {
                            print(error!)
                             print("error lpm")
                        } else {
                            if result != nil {
                                print(result!)
                                print("Success lpm")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func startAudioEngine() {
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
            self.analysisQueue.async {
                self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        
        do{
            try audioEngine.start()
        }catch( _){
            print("error in starting the Audio Engine")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioEngine.stop()
        stopVideo()
        updateLaugh(lpm: totalKetawa!)
        updateLaughToCloudKit()
    }
    
    func updateLaugh(lpm : Double){
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", post?.id ?? ""])
        Post.query(predicate: predicate, result: { (posts) in
            if let foundPost = posts?.first {
                foundPost.record?.setValue(lpm, forKey: "lpm")
                foundPost.save(result: { (posts) in
                    print("Success")
                }) { (error) in
                    print("error")
                }
            }
        }, errorCase: { (error) in
            print(error)
        })
        
    }
    
    func generateAnimatedViews() {
        let image = drand48() > 0.5 ? #imageLiteral(resourceName: "Emoji") : #imageLiteral(resourceName: "Emoji")
        let imageView = UIImageView(image: image)
        let dimension = 20 + drand48() * 10
        imageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        imageView.layer.add(animation, forKey: nil)
        view.addSubview(imageView)
    }
    
    func customPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        //        let randomYShift = 200 + drand48() * 300
        
        let xMax = view.frame.maxX
        let range = CGFloat.random(in: 30...xMax)
        
        path.move(to: CGPoint(x: range, y: 0))
        
        let endPoint = CGPoint(x: range, y: view.frame.maxY)
        
        //    let cp1 = CGPoint(x: 100 - randomYShift, y: 100 )
        //    let cp2 = CGPoint(x: 200 + randomYShift, y: 300 )
        
        path.addLine(to: endPoint)
        //    path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }
}




class ResultsObserver: NSObject, SNResultsObserving {
    var delegate: LaughClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if confidence > 60 {
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        }
    }
}

protocol LaughClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

extension LaughClassifier: LaughClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            print("Recognition: \(identifier)\nConfidence \(confidence)")
        }
    }
}

