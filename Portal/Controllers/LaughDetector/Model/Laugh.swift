//
//  Laugh.swift
//  Portal
//
//  Created by Azam Mukhtar on 01/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import CloudKit
import AVFoundation
import UIKit

class Laugh: CloudKitProtocol, Identifiable, Equatable {
    static func == (lhs: Laugh, rhs: Laugh) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var record: CKRecord?
    var id: CKRecord.ID?
    var postId: String?
    var isLaugh: Int?
    var second: Int?
    var totalDuration: Double?
    
    static var RecordType = "Laugh"
    
    public required init(ckRecord: CKRecord) {
        self.postId = ckRecord["postId"]
        self.isLaugh = ckRecord["isLaugh"]
        self.second = ckRecord["second"]
        self.totalDuration = ckRecord["totalDuration"]
        
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    init(postId: String?, isLaugh: Int?, second: Int?, totalDuration : Double?){
        self.postId = postId
        self.isLaugh = isLaugh
        self.second = second
        self.totalDuration = totalDuration
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["postId"] = postId
        record?["isLaugh"] = isLaugh
        record?["second"] = second
        record?["totalDuration"] = totalDuration
        
        if let record = self.record {
            self.id = record.recordID
        }
    }

}
