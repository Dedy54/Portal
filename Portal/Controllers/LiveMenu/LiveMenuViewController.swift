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
    case thirtyseconds = "30s"
    case gallery = "gallery"
}

class LiveMenuViewController: UIViewController {
    
    @IBOutlet weak var viewLiveMenu: UIView!
    @IBOutlet weak var liveDotImage: UIImageView!{
        didSet{
            liveDotImage.isHidden = (liveMenu != .live)
        }
    }
    @IBOutlet weak var thirtyDotImage: UIImageView!{
        didSet{
            if liveMenu == .thirtyseconds {
                thirtyDotImage.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var galleryDotImage: UIImageView!{
        didSet{
            if liveMenu == .gallery {
                galleryDotImage.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var liveImageView: UIImageView!
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var viewEndLive: UIView!
    
    @IBAction func actionLiveButton(_ sender: Any) {
        
    }
    
    @IBAction func actionThirtyButton(_ sender: Any) {
        self.pickerController.mediaTypes = ["public.movie"]
        self.pickerController.videoQuality = .typeHigh
        self.pickerController.sourceType = .camera
        self.pickerController.showsCameraControls = true
        self.present(self.pickerController, animated: true)
    }
    
    @IBAction func actionGalleryButton(_ sender: Any) {
        self.pickerController.mediaTypes = ["public.movie"]
        self.pickerController.videoQuality = .typeHigh
        self.pickerController.sourceType = .photoLibrary
        self.present(self.pickerController, animated: true)
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        self.isSwitchCamera.toggle()
    }
    
    @IBAction func endLiveVideo(_ sender: Any) {
        self.leaveChannel()
    }
    
    @IBOutlet weak var endLiveButton: UIButton!{
        didSet{
            endLiveButton.layer.cornerRadius = 10
        }
    }
    @IBAction func actionEndLive(_ sender: Any) {
        
    }
    
    @IBOutlet weak var cancelEndLiveButton: UIButton!
    @IBAction func actionCancelEndLive(_ sender: Any) {
        
    }
    
    @IBOutlet weak var liveStartButton: UIButton!
    @IBAction func actionStartLiveButton(_ sender: Any) {
        self.joinChanel()
    }
    
    private var roomName : String? = "portalaja"
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        engine.setLogFilter(AgoraLogFilter.info.rawValue)
        engine.setLogFile(FileCenter.logFilePath())
        return engine
    }()
    private let pickerController : UIImagePickerController = UIImagePickerController()
    var liveMenu: LiveMenu? = .live
    private let maxVideoSession = 4
    
    private var isSwitchCamera = false {
        didSet {
            agoraKit.switchCamera()
        }
    }
    
    private var videoSessions = [VideoSession]() {
        didSet {
            updateBroadcastersView()
        }
    }
    
    private var isLive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerController.delegate = self
        self.loadAgoraKit()
        self.setView(isLive: false)
    }
    
    func setView(isLive: Bool) {
        self.endLiveButton.isHidden = isLive
        self.liveImageView.isHidden = !isLive
        self.liveStartButton.isHidden = isLive
    }
    
}
extension LiveMenuViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let url = info[.mediaURL] as? URL else {
            return
        }
        
        self.pickerController.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "NewPostForm", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewPostFormViewController") as! NewPostFormViewController
        let post = Post(title: "", viewer: 0, lpm: 0, videoUrl: url, isSensitiveContent: false, isLive: false)
        controller.post = post
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated:true, completion: nil)
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
        
        // Step 5, join channel and start group chat
        // If join  channel success, agoraKit triggers it's delegate function
        // 'rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int)'
        agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        
        // Step 6, set speaker audio route
        agoraKit.setEnableSpeakerphone(true)
        
        self.setView(isLive: true)
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
        self.setView(isLive: false)
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
