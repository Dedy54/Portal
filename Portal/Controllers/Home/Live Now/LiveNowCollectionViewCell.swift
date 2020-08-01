//
//  LiveNowCollectionViewCell.swift
//  Portal
//
//  Created by Stendy Antonio on 26/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import CloudKit
import AVFoundation
import UIKit

class LiveNowCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ImageBackgroundStandUpComedian: UIImageView!{
        didSet{
            ImageBackgroundStandUpComedian.clipsToBounds = true
            ImageBackgroundStandUpComedian.layer.cornerRadius = 10
            ImageBackgroundStandUpComedian.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var CaptionStandUpComedian: UILabel!
    @IBOutlet weak var AudienceCount: UILabel!
    @IBOutlet weak var ViewerLogo: UIImageView!
    
    var liveRoom : LiveRoom? {
        didSet{
            AudienceCount.text = "\(liveRoom?.viewer ?? 0)"
            CaptionStandUpComedian.text = "\(liveRoom?.userName ?? "")"
            let emailMember = PreferenceManager.instance.userEmail ?? ""
            let emailMemberPredicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(emailMember)"])
            User.query(predicate: emailMemberPredicate, result: { (result) in
                if let result = result, result.count != 0, let photoUrl = result[0].photoUrl, let data = try? Data(contentsOf: photoUrl) {
                    self.ImageBackgroundStandUpComedian.image = UIImage(data: data)
                }
            }) { (error) in }
        }
    }
    
}
