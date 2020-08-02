//
//  StreamLiveVideoViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AgoraRtcKit
import AgoraRtcCryptoLoader
import AVKit
import SoundAnalysis
import CloudKit

class StreamLiveVideoViewController: UIViewController {
    
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var waitingView: UIView!{
        didSet{
            waitingView.isHidden = true
        }
    }
    @IBAction func actionButtonClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var countViewerLabel: UILabel!
    
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
    
    private var videoSessions = [VideoSession]() {
        didSet {
            updateBroadcastersView()
        }
    }
    
    private let maxVideoSession = 4
    
    var liveRoom : LiveRoom?
    
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.apple.AnalysisQueue")
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = LaughClassifier()
    
    var timerFetchSubscriptionsLiveRoom: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        loadAgoraKit()
        setupLaughDetection()
        updateViewer(setHigher: true)
        fetchSubscriptionsLiveRoom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationBar()
        self.timerFetchSubscriptionsLiveRoom?.invalidate()
        self.updateViewer(setHigher: false)
    }
    
    func setupLaughDetection() {
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAudioEngine()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showHideWaitingView() {
        self.waitingView.isHidden = false
        self.waitingView.alpha = 1
        UIView.animate(withDuration: 2, animations: {
            self.waitingView.alpha = 0
        }) { (finished) in
            self.waitingView.isHidden = true
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
}

extension StreamLiveVideoViewController : LaughClassifierDelegate {
    
    
    func fetchSubscriptionsLiveRoom() {
        timerFetchSubscriptionsLiveRoom = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getUpdateLiveRoomData), userInfo: nil, repeats: true)
    }
    
    @objc func getUpdateLiveRoomData() {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(PreferenceManager.instance.userEmail ?? "")" ])
        LiveRoom.query(predicate: predicate, result: { (result) in
            DispatchQueue.main.async {
                if result?.count != 0 {
                    self.countViewerLabel.text = "\(result?.first?.viewer ?? 0)"
                }
            }
        }) { (error) in }
    }
    
    func updateViewer(setHigher: Bool) {
        let email = PreferenceManager.instance.userEmail ?? ""
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", email])
        LiveRoom.query(predicate: predicate, result: { (foundLiveRooms) in
            if let foundLiveRoom = foundLiveRooms?.first {
                var viewer = 0
                if setHigher {
                    viewer = 1 + (foundLiveRoom.viewer ?? 0)
                } else {
                    viewer = (foundLiveRoom.viewer ?? 0) - 1
                }
                foundLiveRoom.record?.setValue(viewer , forKey: "viewer")
                foundLiveRoom.save(result: { (foundLiveRooms) in
                    print("Success")
                }) { (error) in
                    print("error")
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func updateLPM() {
        let email = PreferenceManager.instance.userEmail ?? ""
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", email])
        LiveRoom.query(predicate: predicate, result: { (foundLiveRooms) in
            if let foundLiveRoom = foundLiveRooms?.first {
                let lpm = (foundLiveRoom.lpm ?? 0.0) + 1
                foundLiveRoom.record?.setValue(lpm , forKey: "lpm")
                foundLiveRoom.save(result: { (foundLiveRooms) in
                    print("Success")
                }) { (error) in
                    print("error")
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func displayPredictionResult(identifier: String, confidence: Double) {
        if identifier == "laugh"{
            
            DispatchQueue.main.async {
                self.updateLPM()
                self.generateAnimatedViews()
                self.generateAnimatedViews()
                self.generateAnimatedViews()
                self.generateAnimatedViews()
                self.generateAnimatedViews()
            }
        }
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
        
        self.delay(1.5) {
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
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

private extension StreamLiveVideoViewController {
    func updateBroadcastersView() {
        // video views layout
        if videoSessions.count == maxVideoSession {
            broadcastersView.reload(level: 0, animated: true)
        } else {
            var rank: Int
            var row: Int
            
            if videoSessions.count == 0 {
                broadcastersView.removeLayout(level: 0)
                return
            } else if videoSessions.count == 1 {
                rank = 1
                row = 1
            } else if videoSessions.count == 2 {
                rank = 1
                row = 2
            } else {
                rank = 2
                row = Int(ceil(Double(videoSessions.count) / Double(rank)))
            }
            
            let itemWidth = CGFloat(1.0) / CGFloat(rank)
            let itemHeight = CGFloat(1.0) / CGFloat(row)
            let itemSize = CGSize(width: itemWidth, height: itemHeight)
            let layout = AGEVideoLayout(level: 0)
                .itemSize(.scale(itemSize))
            
            broadcastersView
                .listCount { [unowned self] (_) -> Int in
                    return self.videoSessions.count
            }.listItem { [unowned self] (index) -> UIView in
                return self.videoSessions[index.item].hostingView
            }
            
            broadcastersView.setLayouts([layout], animated: true)
        }
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
}

private extension StreamLiveVideoViewController {
    func getSession(of uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(of uid: UInt) -> VideoSession {
        if let fetchedSession = getSession(of: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

//MARK: - Agora Media SDK
private extension StreamLiveVideoViewController {
    func loadAgoraKit() {
        guard let channelId = liveRoom?.name, let token = liveRoom?.token else {
            return
        }
        
        setIdleTimerActive(false)
        
        // Step 1, set delegate to inform the app on AgoraRtcEngineKit events
        agoraKit.delegate = self
        // Step 2, set live broadcasting mode
        // for details: https://docs.agora.io/cn/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/setChannelProfile:
        agoraKit.setChannelProfile(.liveBroadcasting)
        // set client role
        agoraKit.setClientRole(.audience)
        
        // Step 3, Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
        agoraKit.enableDualStreamMode(true)
        
        // Step 4, enable the video module
        agoraKit.enableVideo()
        // set video configuration
        
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: CGSize.defaultDimension(),
                frameRate: AgoraVideoFrameRate.defaultValue,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative
            )
        )
        
        // Step 5, join channel and start group chat
        // If join  channel success, agoraKit triggers it's delegate function
        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
        agoraKit.joinChannel(byToken: token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        
        // Step 6, set speaker audio route
        agoraKit.setEnableSpeakerphone(true)
    }
    
    func leaveChannel() {
        // Step 1, release local AgoraRtcVideoCanvas instance
        agoraKit.setupLocalVideo(nil)
        // Step 2, leave channel and end group chat
        agoraKit.leaveChannel(nil)
        
        setIdleTimerActive(true)
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AgoraRtcEngineDelegate
extension StreamLiveVideoViewController: AgoraRtcEngineDelegate {
    
    /// Occurs when the first local video frame is displayed/rendered on the local video view.
    ///
    /// Same as [firstLocalVideoFrameBlock]([AgoraRtcEngineKit firstLocalVideoFrameBlock:]).
    /// @param engine  AgoraRtcEngineKit object.
    /// @param size    Size of the first local video frame (width and height).
    /// @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.
    ///
    /// If the [startPreview]([AgoraRtcEngineKit startPreview]) method is called before the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, then `elapsed` is the time elapsed from calling the [startPreview]([AgoraRtcEngineKit startPreview]) method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let selfSession = videoSessions.first {
            selfSession.updateInfo(resolution: size)
        }
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        if let selfSession = videoSessions.first {
            selfSession.updateChannelStats(stats)
        }
    }
    
    
    /// Occurs when the first remote video frame is received and decoded.
    /// - Parameters:
    ///   - engine: AgoraRtcEngineKit object.
    ///   - uid: User ID of the remote user sending the video stream.
    ///   - size: Size of the video frame (width and height).
    ///   - elapsed: Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        guard videoSessions.count <= maxVideoSession else {
            return
        }
        
        let userSession = videoSession(of: uid)
        userSession.updateInfo(resolution: size)
        agoraKit.setupRemoteVideo(userSession.canvas)
    }
    
    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([AgoraRtcEngineKit userOfflineBlock:]).
    ///
    /// There are two reasons for users to be offline:
    ///
    /// - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
    /// - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
    ///
    ///  @param engine AgoraRtcEngineKit object.
    ///  @param uid    ID of the user or host who leaves a channel or goes offline.
    ///  @param reason Reason why the user goes offline, see AgoraUserOfflineReason.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() where session.uid == uid {
            indexToDelete = index
            break
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            // release canvas's view
            deletedSession.canvas.view = nil
        }
    }
    
    /// Reports the statistics of the video stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        if let session = getSession(of: stats.uid) {
            session.updateVideoStats(stats)
        }
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        if let session = getSession(of: stats.uid) {
            session.updateAudioStats(stats)
        }
    }
    
    /// Reports a warning during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning code: \(warningCode.description)")
    }
    
    /// Reports an error during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("warning code: \(errorCode.description)")
    }
}
