//
//  NewComerViewController.swift
//  Portal
//
//  Created by Stendy Antonio on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class NewComerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var postList : [Post] = []
    
    @IBOutlet weak var collectionViewNewComer: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    
    func setList(){
        showIndicator()
        Post.all(result: { (posts) in
            self.postList = posts!
            self.postList.reverse()
            DispatchQueue.main.async {
                self.collectionViewNewComer.reloadData()
                self.hideIndicator()
            }
        }) { (error) in
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewComerCollectionViewCell
        let post = postList[indexPath.row]
        cell.AudienceCount.text = "\(post.lpm ?? 0)"
        cell.CaptionStandUp.text = post.title
        post.getThumbnailCloudKit(completion: { (thumbnailImage) in
            cell.ImageBackgroundStandUpComedian.image = thumbnailImage
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "New comer"
        showNavigationBar()
        setList()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
