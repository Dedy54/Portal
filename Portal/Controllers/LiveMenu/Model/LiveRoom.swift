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
    
    static var RecordType = "Programs"
    
    public required init(ckRecord: CKRecord) {
        self.name = ckRecord["name"]
        self.token = ckRecord["token"]
        self.userReference = ckRecord["userReference"]
        
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    init(name: String, token: String, userReference: CKRecord.Reference){
        self.name = name
        self.token = token
        self.userReference = userReference
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["name"] = name
        record?["token"] = token
        record?["userReference"] = userReference
        
        if let record = self.record {
            self.id = record.recordID
        }
    }
    
    static func == (lhs: LiveRoom, rhs: LiveRoom) -> Bool {
        return lhs.id == rhs.id
    }

}
