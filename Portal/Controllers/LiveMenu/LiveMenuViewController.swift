//
//  LiveMenuViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 28/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AgoraRtcKit
import AgoraRtcCryptoLoader

enum LiveMenu : String {
    case live = "live"
    case inlive = "inlive"
    case thirtyseconds = "30s"
    case gallery = "gallery"
    case recording = "recording"
}

class LiveMenuViewController: UIViewController {
    
    @IBOutlet weak var viewLiveMenu: UIView!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var liveDotImage: UIImageView!{
        didSet{
            liveDotImage.isHidden = false
        }
    }
    @IBOutlet weak var thirtyLabel: UILabel!
    @IBOutlet weak var thirtyDotImage: UIImageView!{
        didSet{
            thirtyDotImage.isHidden = false
        }
    }
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var galleryDotImage: UIImageView!{
        didSet{
            galleryDotImage.isHidden = false
        }
    }
    
    @IBOutlet weak var liveImageView: UIImageView!
    @IBOutlet weak var waitingView: UIView!{
        didSet{
            waitingView.isHidden = true
        }
    }
    @IBOutlet weak var broadcastersView: AGEVideoContainer!{
        didSet{
            self.broadcastersView.clipsToBounds = true
            self.broadcastersView.layer.cornerRadius = 10
            self.broadcastersView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    @IBOutlet weak var previewView: CKFPreviewView! {
        didSet {
            let session = CKFVideoSession()
            session.delegate = self
            
            self.previewView.autorotate = true
            self.previewView.session = session
            self.previewView.previewLayer?.videoGravity = .resizeAspectFill
            
            self.previewView.clipsToBounds = true
            self.previewView.layer.cornerRadius = 10
            self.previewView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @IBOutlet weak var viewEndLive: UIView!
    
    @IBAction func actionLiveButton(_ sender: Any) {
        self.liveMenu = .live
        self.showHideWaitingView()
    }
    
    @IBAction func actionThirtyButton(_ sender: Any) {
        self.showHideWaitingView()
        self.liveMenu = .thirtyseconds
        self.setViewSourceVideo()
    }
    
    @IBAction func actionGalleryButton(_ sender: Any) {
        self.showHideWaitingView()
        self.pickerController.mediaTypes = ["public.movie"]
        self.pickerController.videoQuality = .typeHigh
        self.pickerController.sourceType = .photoLibrary
        self.pickerController.allowsEditing = false
        self.present(self.pickerController, animated: true)
    }
    
    @IBOutlet weak var countDownLabel: UILabel!{
        didSet{
            self.countDownLabel.isHidden = true
        }
    }
    @IBOutlet weak var rotateCameraButton: UIButton!
    @IBAction func rotateCamera(_ sender: Any) {
        self.showHideWaitingView()
        self.isSwitchCamera.toggle()
        switch liveMenu {
        case .live:
            agoraKit.switchCamera()
            previewView.session?.stop()
        case .inlive:
            agoraKit.switchCamera()
            previewView.session?.stop()
        case .thirtyseconds:
            agoraKit.stopPreview()
            if let session = self.previewView.session as? CKFVideoSession {
                session.cameraPosition = isBackCamera ? .back : .front
            }
        case .recording:
            agoraKit.stopPreview()
            if let session = self.previewView.session as? CKFVideoSession {
                session.cameraPosition = isBackCamera ? .back : .front
            }
        default:
            print("default")
        }
    }
    
    @IBOutlet weak var rotateCameraBottomButton: UIButton!
    @IBAction func rotateBottomCamera(_ sender: Any) {
        self.showHideWaitingView()
        self.isSwitchCamera.toggle()
        switch liveMenu {
        case .live:
            agoraKit.switchCamera()
        case .inlive:
            agoraKit.switchCamera()
        case .thirtyseconds:
            if let session = self.previewView.session as? CKFVideoSession {
                session.cameraPosition = isBackCamera ? .front : .back
            }
        case .recording:
            if let session = self.previewView.session as? CKFVideoSession {
                session.cameraPosition = isBackCamera ? .front : .back
            }
        default:
            print("default")
        }
    }
    
    @IBOutlet weak var endLiveVideo: UIButton!{
        didSet{
            endLiveVideo.layer.cornerRadius = 5
        }
    }
    @IBAction func endLiveVideo(_ sender: Any) {
        self.showHideWaitingView()
        self.leaveChannel()
    }
    
    @IBOutlet weak var endLiveButton: UIButton!{
        didSet{
            endLiveButton.layer.cornerRadius = 5
        }
    }
    @IBAction func actionEndLive(_ sender: Any) {
        self.showHideWaitingView()
    }
    
    @IBOutlet weak var cancelEndLiveButton: UIButton!
    @IBAction func actionCancelEndLive(_ sender: Any) {
        
    }
    
    @IBOutlet weak var liveStartButton: UIButton!
    @IBAction func actionStartLiveButton(_ sender: Any) {
        self.showHideWaitingView()
        self.joinChanel()
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func actionCloseButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func actionRecordButton(_ sender: Any) {
        self.showHideWaitingView()
        if liveMenu == .thirtyseconds {
            self.liveMenu = .recording
            if let session = self.previewView.session as? CKFVideoSession {
                self.startTimer()
                self.setViewSourceVideo()
                session.record({ (url) in
                    self.movePreview(url: url)
                }) { (_) in }
            }
        } else if liveMenu == .recording {
            self.liveMenu = .thirtyseconds
            if let session = self.previewView.session as? CKFVideoSession {
                if session.isRecording {
                    session.stopRecording()
                    self.timer?.invalidate()
                }
            }
            self.setViewSourceVideo()
        }
        
    }
    
    private var roomName : String? = "portalaja"
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
    private let pickerController : UIImagePickerController = UIImagePickerController()
    
    var liveMenu: LiveMenu? = .live {
        didSet {
            self.setViewSourceVideo()
        }
    }
    private let maxVideoSession = 4
    
    private var isSwitchCamera = false {
        didSet {
            self.isBackCamera = isSwitchCamera
        }
    }
    private var isBackCamera = true
    
    var timer: Timer?
    var countTimer = 0
    
    private var videoSessions = [VideoSession]() {
        didSet {
            self.updateBroadcastersView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerController.delegate = self
        self.loadAgoraKit()
        self.setViewSourceVideo()
        self.showHideWaitingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    func setViewSourceVideo(){
        switch liveMenu {
        case .live:
            self.viewLiveMenu.isHidden = false
            self.liveDotImage.isHidden = false
            self.thirtyDotImage.isHidden = true
            self.galleryDotImage.isHidden = true
            
            self.liveLabel.textColor = UIColor.init(named: "ColorYellow")
            self.thirtyLabel.textColor = UIColor.white
            self.galleryLabel.textColor = UIColor.white
            
            self.broadcastersView.isHidden = false
            self.agoraKit.stopPreview()
            self.agoraKit.startPreview()
            self.previewView.isHidden = false
            self.previewView.session?.stop()
            
            self.endLiveVideo.isHidden = true
            self.liveImageView.isHidden = true
            self.liveStartButton.isHidden = false
            
            self.closeButton.isHidden = false
            self.countDownLabel.isHidden = true
            
            self.recordButton.isHidden = true
            self.rotateCameraButton.isHidden = true
            self.rotateCameraBottomButton.isHidden = false
            
        case .inlive:
            self.viewLiveMenu.isHidden = true
            self.liveDotImage.isHidden = false
            self.thirtyDotImage.isHidden = true
            self.galleryDotImage.isHidden = true
            
            self.liveLabel.textColor = UIColor.init(named: "ColorYellow")
            self.thirtyLabel.textColor = UIColor.white
            self.galleryLabel.textColor = UIColor.white
            
            self.broadcastersView.isHidden = false
            self.agoraKit.startPreview()
            self.previewView.isHidden = true
            self.previewView.session?.stop()
            
            self.endLiveVideo.isHidden = false
            self.liveImageView.isHidden = false
            self.liveStartButton.isHidden = true
            
            self.closeButton.isHidden = true
            self.countDownLabel.isHidden = true
            
            self.recordButton.isHidden = true
            self.rotateCameraButton.isHidden = false
            self.rotateCameraBottomButton.isHidden = true
            
        case .thirtyseconds:
            self.viewLiveMenu.isHidden = false
            self.liveDotImage.isHidden = true
            self.thirtyDotImage.isHidden = false
            self.galleryDotImage.isHidden = true
            
            self.liveLabel.textColor = UIColor.white
            self.thirtyLabel.textColor = UIColor.init(named: "ColorYellow")
            self.galleryLabel.textColor = UIColor.white
            
            self.broadcastersView.isHidden = true
            self.agoraKit.stopPreview()
            self.previewView.isHidden = false
            self.previewView.session?.stop()
            self.previewView.session?.start()
            
            self.endLiveVideo.isHidden = true
            self.liveImageView.isHidden = true
            self.liveStartButton.isHidden = true
            
            self.closeButton.isHidden = false
            self.countDownLabel.isHidden = true
            
            self.recordButton.isHidden = false
            self.recordButton.setImage(UIImage(named: "Record Button"), for: .normal)
            self.rotateCameraButton.isHidden = true
            self.rotateCameraBottomButton.isHidden = false
        case .recording:
            self.viewLiveMenu.isHidden = true
            self.liveDotImage.isHidden = true
            self.thirtyDotImage.isHidden = false
            self.galleryDotImage.isHidden = true
            
            self.liveLabel.textColor = UIColor.white
            self.thirtyLabel.textColor = UIColor.init(named: "ColorYellow")
            self.galleryLabel.textColor = UIColor.white
            
            self.broadcastersView.isHidden = true
            self.agoraKit.stopPreview()
            self.previewView.isHidden = false
            self.previewView.session?.stop()
            self.previewView.session?.start()
            
            self.endLiveVideo.isHidden = true
            self.liveImageView.isHidden = true
            self.liveStartButton.isHidden = true
            
            self.closeButton.isHidden = true
            self.countDownLabel.isHidden = false
            
            self.recordButton.isHidden = false
            self.recordButton.setImage(UIImage(named: "Stop Record Btn"), for: .normal)
            self.rotateCameraButton.isHidden = true
            self.rotateCameraBottomButton.isHidden = true
        default:
            self.liveLabel.textColor = UIColor.white
            self.thirtyLabel.textColor = UIColor.white
            self.galleryLabel.textColor = UIColor.init(named: "ColorYellow")
            
            self.broadcastersView.isHidden = false
            self.previewView.isHidden = true
        }
    }
    
    func startTimer() {
        self.countTimer = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: true)
    }
    
    @objc func stopTimer() {
        self.countTimer += 1
        self.countDownLabel.text = "00:0\(self.countTimer)"
        if self.countTimer == 30, let session = self.previewView.session as? CKFVideoSession {
            if session.isRecording {
                session.stopRecording()
                self.timer?.invalidate()
                self.countTimer = 0
            }
        }
    }
}
extension LiveMenuViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func movePreview(url: URL) {
        let storyboard = UIStoryboard(name: "PreviewVideo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PreviewVideoViewController") as! PreviewVideoViewController
        controller.url = url
        if AVURLAsset(url: url).duration.seconds >= 30 {
            self.cropVideo(sourceURL: url, startTime: 0, endTime: 30) { (url) in
                controller.url = url
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated:true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let url = info[.mediaURL] as? URL else {
            return
        }
        
        self.pickerController.dismiss(animated: true, completion: nil)
        self.movePreview(url: url)
    }
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
    
}

private extension LiveMenuViewController {
    func updateBroadcastersView() {
        // video views layout
        
        guard broadcastersView != nil else { return }
        
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

extension LiveMenuViewController : CKFSessionDelegate {
    
    func didChangeValue(session: CKFSession, value: Any, key: String) {
        print("key : \(key)")
    }
    
}

private extension LiveMenuViewController {
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
private extension LiveMenuViewController {
    func loadAgoraKit() {
        
        setIdleTimerActive(false)
        
        // Step 1, set delegate to inform the app on AgoraRtcEngineKit events
        agoraKit.delegate = self
        // Step 2, set live broadcasting mode
        // for details: https://docs.agora.io/cn/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/setChannelProfile:
        agoraKit.setChannelProfile(.liveBroadcasting)
        // set client role
        agoraKit.setClientRole(.broadcaster)
        
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
        
        // if current role is broadcaster, add local render view and start preview
        addLocalSession()
        
        agoraKit.startPreview()
    }
    
    func joinChanel() {
        guard let channelId = self.roomName else {
            return
        }
        
        agoraKit.startPreview()
        
        // Step 5, join channel and start group chat
        // If join  channel success, agoraKit triggers it's delegate function
        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
        agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        
        // Step 6, set speaker audio route
        agoraKit.setEnableSpeakerphone(true)
        
        liveMenu = .inlive
        
        setViewSourceVideo()
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.updateInfo(fps: AgoraVideoFrameRate.defaultValue.rawValue)
        videoSessions.append(localSession)
        agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        setIdleTimerActive(true)
        liveMenu = .live
        setViewSourceVideo()
    }
}

// MARK: - AgoraRtcEngineDelegate
extension LiveMenuViewController: AgoraRtcEngineDelegate {
    
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
