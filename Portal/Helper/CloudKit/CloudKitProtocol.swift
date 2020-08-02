//
//  CloudKitProtocol.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 25/05/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import CloudKit
import SwiftUI

protocol CloudKitProtocol {
    var record: CKRecord? { get set }
    init(ckRecord: CKRecord)
}

extension CloudKitProtocol {
    
    static var recordType: String {
        return String(describing: self)
    }
    
    func save(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase,
              result: @escaping (Self?) -> (),
              errorCase: @escaping (Error?) -> ()) {
        
        guard let record = self.record else {return}
        
        database?.save(record) { (record, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            if let postRecord = record {
                result(Self(ckRecord: postRecord))
                return
            }
            
            result(nil)
        }
    }
    
    func update(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase, predicate: NSPredicate,
                       result: @escaping ([Self]?) -> (),
                       errorCase: @escaping (Error) -> ()) {
        
        guard var record = self.record else {return}
        
        Self.queryRecord(predicate: predicate, retrieving: { (foundRecord) in
            
            record = foundRecord
            
            database?.save(record, completionHandler: { (record, error) in
                if let error = error {
                    errorCase(error)
                    return
                }
                
                if let postRecord = record {
                    result([Self(ckRecord: postRecord)])
                    return
                }
                
                result(nil)
            })
            
        }) { (_, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Records updated")
            }
        }
    }
    
    static func queryRecord(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase, predicate: NSPredicate, retrieving: @escaping (CKRecord) -> Void, completion: @escaping (CKQueryOperation.Cursor?, Error?) -> Void) {
        
        let query = CKQuery(recordType: Self.recordType, predicate: predicate)
        let sortCreation = NSSortDescriptor(key: "creationDate", ascending: false)
        query.sortDescriptors = [sortCreation]
        
        let queryOperation = CKQueryOperation(query: query)
        
        database?.add(queryOperation)
        
        queryOperation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                retrieving(record)
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else {
                print("An error occurred during record querying.")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(cursor, error)
            }
        }
    }
    
    static func all(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase,
                    withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                    result: @escaping ([Self]?) -> (),
                    errorCase: @escaping (Error) -> ()) {
        let predicate = NSPredicate.init(value: true)
        let query = CKQuery.init(recordType: Self.recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors

        database?.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }

            result(
                records?.map({ (record) -> Self in

                    return Self(ckRecord: record)
                })
            )
        }
    }
    
    static func query(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase,
                    predicate: NSPredicate,
                    withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                    result: @escaping ([Self]?) -> (),
                    errorCase: @escaping (Error) -> ()) {
        let query = CKQuery.init(recordType: Self.recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors

        database?.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }

            result(
                records?.map({ (record) -> Self in

                    return Self(ckRecord: record)
                })
            )
        }
    }
    
    static func delete(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase, predicate: NSPredicate, completion: @escaping () -> Void) {
        Self.queryRecord(predicate: predicate, retrieving: { (record) in
            database?.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                guard let recordID = recordID else { return }
                print("record with id: \(recordID)")
                completion()
            })
        }) { (_, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Records deleted")
                completion()
            }
        }
    }
    
    static func deleteAll(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase, completion: @escaping () -> Void) {
        Self.queryRecord(predicate: NSPredicate(value: true), retrieving: { (record) in
            database?.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                guard let recordID = recordID else { return }
                print("record with id: \(recordID)")
                
//                completion()
            })
        }) { (_, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Records deleted")
                completion()
            }
            
        }
    }
    
    static func selectById(inDatabase database: CKDatabase? = CloudKitService.shared.container.publicCloudDatabase,
                           id: CKRecord.ID,
                       withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                       result: @escaping ([Self]?) -> (),
                       errorCase: @escaping (Error) -> ()) {
//           let query = CKQuery.init(recordType: Self.recordType, predicate: predicate)
//           query.sortDescriptors = sortDescriptors

//        database?.fetch(withRecordID: id, completionHandler: { (records, error) in
//            if let error = error {
//                             errorCase(error)
//                             return
//                         }
//
//                         result(
//                             records?.map({ (record) -> Self in
//
//                                return Self(ckRecord: record)
//                             })
//                         )
//        })
//           database?.perform(query, inZoneWith: nil) { (records, error) in
//               if let error = error {
//                   errorCase(error)
//                   return
//               }
//
//               result(
//                   records?.map({ (record) -> Self in
//
//                       return Self(ckRecord: record)
//                   })
//               )
//           }
       }
}
