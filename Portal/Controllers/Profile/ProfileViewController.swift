//
//  NotificationViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileSC: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var laughCountLabel: UILabel!
    
    @IBOutlet weak var noVideoLabel: UILabel!
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    var user : User? = nil
    var postList : [Post] = []
    var postLive : [Post] = []
    var postNotLive : [Post] = []
    
    var laughList : [Double] = []
    
    var videoUrl : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.viewTapped(gestureRecognizer:)))
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        profileCollectionView.backgroundColor = UIColor.clear
        //        profileCollectionView = UICollectionView(frame: .zero, collectionViewLayout: subCollectionViewLayout!)
        
        // Do any additional setup after loading the view.
        hideNavigationBar()
        
        //        profileSC.addTarget(self, action: Selector(("segmentedControlValueChanged:")), for:.touchUpInside)
        setList()
        setData()
    }
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            postList = postNotLive
            profileCollectionView.reloadData()
            checkVideoIsEmptyOrNot(post: postList)
        case 1:
            postList = postLive
            profileCollectionView.reloadData()
            checkVideoIsEmptyOrNot(post: postList)
        default:
            break
        }
    }
    
    //    func segmentedControlValueChanged(segment: UISegmentedControl) {
    //
    //    }
    
    func setData(){
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(PreferenceManager.instance.userEmail ?? "")" ])
        User.query(predicate: predicate, result: { (users) in
            self.user = users?.first
            self.setUserDataToView(user: (users?.first))
        }) { (error) in
            print(error)
        }
    }
    
    func setUserDataToView(user : User?) {
        DispatchQueue.main.async {
            self.nameLabel.text = user?.name
            self.statusLabel.text = user?.status
            self.followersCountLabel.text = "\(user!.followers ?? 0)"
            self.followingCountLabel.text = "\(user!.following ?? 0)"
            let laugh = self.laughList.reduce(0, +)
            self.laughCountLabel.text = String(laugh)
        }
    }
    
    func setList(){
        self.showIndicator()
        Post.all(result: { (posts) in
            self.setListObject(posts: posts)
            DispatchQueue.main.async {
                self.hideIndicator()
            }
        }) { (error) in
            print(error)
        }
    }
    
    func setListObject(posts: [Post]?) {
        if let posts = posts {
            for post in posts {
                laughList.append(post.lpm!)
            }
        }
        
        postList = posts!.filter { $0.email == PreferenceManager.instance.userEmail}
        
        postLive = postList.filter { $0.isLive == 1 }
        postNotLive = postList.filter { $0.isLive == 0 }
        
        DispatchQueue.main.async {
            switch self.profileSC.selectedSegmentIndex {
            case 0:
                self.postList = self.postNotLive
                self.profileCollectionView.reloadData()
                self.checkVideoIsEmptyOrNot(post: self.postList)
            case 1:
                self.postList = self.postLive
                self.profileCollectionView.reloadData()
                self.checkVideoIsEmptyOrNot(post: self.postList)
            default:
                break
            }
        }
    }
    
    func checkVideoIsEmptyOrNot(post : [Post]){
        if post.isEmpty {
            noVideoLabel.isHidden = false
        } else {
            noVideoLabel.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProfileCollectionViewCell
        let post = postList[indexPath.row]
        cell.AudienceCount.text = "\(post.lpm ?? 0)"
        cell.CaptionStandUp.text = post.title
        post.getThumbnailCloudKit { (thumbnailImage) in
            cell.ImageBackgroundStandUpComedian.image = thumbnailImage
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let post = postList[indexPath.row]
         performSegue(withIdentifier: "toVideoPlayerStats", sender: post)
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if let destination = segue.destination as? VideoPlayerStatsViewController {
             destination.post = sender as? Post
         }
     }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
}

