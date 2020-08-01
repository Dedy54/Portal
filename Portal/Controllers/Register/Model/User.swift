//
//  User.swift
//  Portal
//
//  Created by Azam Mukhtar on 31/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import CloudKit

class User: CloudKitProtocol, Identifiable, Equatable {
    
    public var record: CKRecord?
    var id: CKRecord.ID?
    var name: String?
    var email: String?
    var userId: String?
//    var photo : CKAsset?
    var photoUrl : URL?
    var status : String?
    var followers : Int?
    var following : Int?
    var lpm : Int?
    
    static var RecordType = "User"
    
    public required init(ckRecord: CKRecord) {
        self.name = ckRecord["name"]
        self.email = ckRecord["email"]
//        self.photo = ckRecord["photo"]
        self.userId = ckRecord["userId"]
        self.status = ckRecord["status"]
        self.followers = ckRecord["followers"]
        self.following = ckRecord["following"]
        self.lpm = ckRecord["lpm"]
        
        self.record = ckRecord
        self.id = ckRecord.recordID
    }
    
    
    init(name: String, email: String, userId : String, followers : Int?, following : Int?, lpm : Int?, status : String){
        self.name = name
        self.email = email
//        self.photo = CKAsset(fileURL: photoUrl!)
//        self.photoUrl = photoUrl
        self.userId = userId
        self.status = status
        self.followers = followers
        self.following = following
        self.lpm = lpm
        
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record?["name"] = name
        record?["email"] = email
//        record?["photo"] = CKAsset(fileURL: photoUrl!)
        record?["userId"] = userId
        record?["status"] = status
        record?["followers"] = followers
        record?["following"] = following
        record?["lpm"] = lpm
        
        if let record = self.record {
            self.id = record.recordID
        }
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
