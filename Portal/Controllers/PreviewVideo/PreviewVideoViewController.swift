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
import CloudKit

class PreviewVideoViewController: UIViewController {
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Preview"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(addTappedPost))
        
        if let url = self.url {
            let player = AVPlayerViewController()
            player.player = AVPlayer(url: url)
            player.view.frame = self.view.bounds
            
            self.view.addSubview(player.view)
            self.addChild(player)
            
            player.player?.play()
        }
    }
    
    @objc func addTappedPost(sender: UIBarButtonItem) {
        // note CKRecord.Reference(record: CKRecord(recordType: "Post"), change with user id registered
        if let url = self.url {
            let storyboard = UIStoryboard(name: "NewPostForm", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NewPostFormViewController") as! NewPostFormViewController
            let post = Post(title: "", viewer: 0, lpm: 0, videoUrl: url, isSensitiveContent: 0, isLive: 0, userReference: CKRecord.Reference(record: CKRecord(recordType: "Post"), action: .none))
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

}
