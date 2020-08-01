//
//  Post.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import CloudKit
import AVFoundation
import UIKit

class Post: CloudKitProtocol, Identifiable, Equatable {
    
    public var record: CKRecord?
    var id: CKRecord.ID?
    var title: String?
    var viewer: Int?
    var lpm: Double?
    var video : CKAsset?
    var videoUrl : URL?
    var isSensitiveContent: Int?
    var userReference : CKRecord.Reference?
    var isLive: Int?
    var email: String?
    
    static var RecordType = "Post"
    
    public required init(ckRecord: CKRecord) {
        self.title = ckRecord["title"]
        self.viewer = ckRecord["viewer"]
        self.lpm = ckRecord["lpm"]
        self.video = ckRecord["video"]
        self.isSensitiveContent = ckRecord["isSensitiveContent"]
        self.userReference = ckRecord["userReference"]
        self.isLive = ckRecord["isLive"]
        self.email = ckRecord["email"]
        
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    init(title: String?, viewer: Int?, lpm: Double?, videoUrl: URL, isSensitiveContent: Int?, isLive: Int?, userReference: CKRecord.Reference?, email: String?){
        self.title = title
        self.viewer = viewer
        self.lpm = lpm
        self.isSensitiveContent = isSensitiveContent
        self.video = CKAsset(fileURL: videoUrl)
        self.videoUrl = videoUrl
        self.userReference = userReference
        self.isLive = isLive
        self.email = email
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["title"] = title
        record?["viewer"] = viewer
        record?["lpm"] = lpm
        record?["video"] = CKAsset(fileURL: videoUrl)
        record?["isSensitiveContent"] = isSensitiveContent
        record?["isLive"] = isLive
        record?["userReference"] = userReference
        record?["email"] = email
        
        if let record = self.record {
            self.id = record.recordID
        }
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getThumbnail(completion: @escaping ((_ image: UIImage?)->Void)) {
        guard let url = self.videoUrl else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    

   func getThumbnailCloudKit(completion: @escaping ((_ image: UIImage?)->Void)) {
    let videoData = NSData(contentsOf: (video?.fileURL)!)
          
          let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
          let destinationPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent("filename.mov", isDirectory: false)
          
          FileManager.default.createFile(atPath: destinationPath!.path, contents:videoData as Data?, attributes:nil)
          
          videoUrl = destinationPath
          
          DispatchQueue.global().async {
            let asset = AVAsset(url: destinationPath!)
              let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
              avAssetImageGenerator.appliesPreferredTrackTransform = true
              let thumnailTime = CMTimeMake(value: 2, timescale: 1)
              do {
                  let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                  let thumbImage = UIImage(cgImage: cgThumbImage)
                  DispatchQueue.main.async {
                      completion(thumbImage)
                  }
              } catch {
                  print(error.localizedDescription)
                  DispatchQueue.main.async {
                      completion(nil)
                  }
              }
          }
      }
}
