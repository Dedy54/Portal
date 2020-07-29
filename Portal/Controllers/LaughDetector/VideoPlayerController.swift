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

class VideoPlayerController: UIViewController, GenderClassifierDelegate {
    let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    var player : AVPlayer?
    
 
    
    @IBOutlet weak var asd: UIView!

    
    
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = LaughClassifier()
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.viewTapped(gestureRecognizer:)))
               
               view.addGestureRecognizer(tapGesture)
        hideNavigationBar()
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
        playVideo()
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
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame =  self.view.bounds
        playerLayer.addSublayer(asd.layer)
        self.view.layer.addSublayer(playerLayer)
        player?.play()
    }
    
    func stopVideo(){
        player?.pause()
    }
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func displayPredictionResult(identifier: String, confidence: Double) {
         
         print("Recognition: \(identifier)\nConfidence \(confidence)")
         //
         
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
            print("error in starting the Audio Engin")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioEngine.stop()
        stopVideo()
    }
}


class ResultsObserver: NSObject, SNResultsObserving {
    var delegate: GenderClassifierDelegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
        
        let confidence = classification.confidence * 100.0
        
        if confidence > 60 {
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        }
    }
}

protocol GenderClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

extension LaughClassifier: GenderClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            print("Recognition: \(identifier)\nConfidence \(confidence)")
            //            self.transcribedText.text = ("Recognition: \(identifier)\nConfidence \(confidence)")
        }
    }
}
