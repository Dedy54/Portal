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
    
    public required init(ckRecord: CKRecord) {
        self.name = ckRecord["name"]
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    init(name: String, pendidikan: String, jabatan: String, email: String, alamat: String){
        self.name = name
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["name"] = name
        
        if let record = self.record {
            self.id = record.recordID
        }
    }
    
    static func == (lhs: LiveRoom, rhs: LiveRoom) -> Bool {
        return lhs.id == rhs.id
    }

}
