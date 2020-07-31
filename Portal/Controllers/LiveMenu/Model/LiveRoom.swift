//
//  LiveRoom.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import CloudKit

class LiveRoom: CloudKitProtocol, Identifiable, Equatable {
    
    public var record: CKRecord?
    var id: CKRecord.ID?
    var name: String?
    var token: String?
    var userReference : CKRecord.Reference?
    var email : String?
    var uid : String?
    var viewer: Int?
    var lpm: Double?
    
    static var RecordType = "LiveRooms"
    
    public required init(ckRecord: CKRecord) {
        self.name = ckRecord["name"]
        self.token = ckRecord["token"]
        self.userReference = ckRecord["userReference"]
        self.email = ckRecord["email"]
        self.uid = ckRecord["uid"]
        self.viewer = ckRecord["viewer"]
        self.lpm = ckRecord["lpm"]
        
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    init(name: String, token: String, userReference: CKRecord.Reference, email: String, uid: String, viewer: Int, lpm: Double){
        self.name = name
        self.token = token
        self.userReference = userReference
        self.email = email
        self.uid = uid
        self.viewer = viewer
        self.lpm = lpm
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["name"] = name
        record?["token"] = token
        record?["userReference"] = userReference
        record?["email"] = email
        record?["uid"] = uid
        record?["viewer"] = viewer
        record?["lpm"] = lpm
        
        if let record = self.record {
            self.id = record.recordID
        }
    }
    
    static func == (lhs: LiveRoom, rhs: LiveRoom) -> Bool {
        return lhs.id == rhs.id
    }

}
