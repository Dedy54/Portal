//
//  HomeViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var postList : [Post] = []
    
    @IBOutlet weak var collectionViewHome: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.viewTapped(gestureRecognizer:)))

        tapGesture.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapGesture)
        hideNavigationBar()
        
    }
    
    func setList(){
        showIndicator()
         Post.all(result: { (posts) in
            self.postList = posts!
            DispatchQueue.main.async {
                self.collectionViewHome.reloadData()
                self.hideIndicator()
            }
            
         }) { (error) in
             print(error)
         }
     }
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let post = postList[indexPath.row]
        cell.ViewerCount.text = "\(post.lpm ?? 0)"
              cell.LabelStandUpComedian.text = post.title
              post.getThumbnailCloudKit(completion: { (thumbnailImage) in
                  cell.ImageStandUpComedianBackground.image = thumbnailImage
              })
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = postList[indexPath.row]
        performSegue(withIdentifier: "toVideoPlayer", sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? VideoPlayerController {
            destination.post = sender as? Post
        }
    }
    
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
        setList()
    }
}
