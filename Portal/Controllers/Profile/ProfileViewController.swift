//
//  NotificationViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileSC: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var laughCountLabel: UILabel!
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    let user : User?
    let postList : [Post] = []
    let postLive : [Post] = []
    let postNotLive : [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
        hideNavigationBar()
        
        profileSC.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents:.TouchUpInside)

    }
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            postList = postNotLive
            profileCollectionView.reloadData()
        case 1:
            postList = postLive
            profileCollectionView.reloadData()
        default:
            break
        }
    }
    
    func setData(){
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(PreferenceManager.instance.userEmail)"])
        User.query(predicate: predicate, result: { (users) in
            user = users?.first
        }) { (error) in
            print(error)
        }
    }
    
    func setUserDataToView(user : User) {
        nameLabel.text = user.name
        statusLabel.text = user.status
        followersCountLabel.text = String("\(user.followers)")
        followingCountLabel.text = String("\(user.following)")
        
    }
    
    func setList(){
        Post.all(result: { (posts: [posts]?) in
            setListObject(posts: posts)
        }) { (error) in
            print(error)
        }
    }
    func setListObject(posts: [Post]?){
        postList = posts.filter { $0.userReference == PreferenceManager.instance.userEmail}
        
        postLive = postList.filter { $0.isLive == true }
        postNotLive = postList.filter { $0.isLive == false }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList?.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProfileCollectionViewCell
            let post = postList[indexPath.row]
            cell.AudienceCount.text = String("\(post.lpm)")
            cell.CaptionStandUp.text = post.title
    
            return cell
        
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
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
}

