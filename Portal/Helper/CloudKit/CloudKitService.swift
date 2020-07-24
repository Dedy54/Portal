//
//  CloudKitService.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 25/05/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import CloudKit

class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    let container = CKContainer.default()
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let sharedDatabase = CKContainer.default().sharedCloudDatabase
}
