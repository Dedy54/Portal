//
//  OpenMicViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class OpenMicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideNavigationBar()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func sampleCode() {
        // add inDatabase: CloudKitService.shared.publicDatabase default publicCloudDatabase
        // add inDatabase: CloudKitService.shared.privateDatabase
        // add inDatabase: CloudKitService.shared.sharedDatabase
        
        // create
//        LiveRoom(name: "test-room-live").save(inDatabase: CloudKitService.shared.sharedDatabase, result: { (result) in
//            
//        }) { (error) in
//
//        }
        
        // room query
        let predicateRoomName = NSPredicate(format: "name=%@", "test-room-live")
        LiveRoom.query(predicate: predicateRoomName, result: { (liveRooms) in
            print("Success \(liveRooms?.count ?? 0)")
        }) { (error) in
        
        }
        
        // delete where
        let predicateMembersTest = NSPredicate(format: "%K == %@", argumentArray: ["name", "test-room-live"])
        LiveRoom.delete(predicate: predicateMembersTest, completion: {
            print("Success delete LiveRoom test name")
        })
        
        // delete all
        LiveRoom.deleteAll {
            print("Success delete LiveRoom")
        }
        
        // update
        let name = "test-room-live"
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", name])
        LiveRoom.query(predicate: predicate, result: { (foundLiveRooms) in
            if let foundLiveRoom = foundLiveRooms?.first {
                foundLiveRoom.record?.setValue("testnameupdate", forKey: "name")
                foundLiveRoom.save(result: { (foundLiveRooms) in
                    print("Success")
                }) { (error) in
                    print("error")
                }
            }
        }) { (error) in
            print(error)
        }
    }
}
