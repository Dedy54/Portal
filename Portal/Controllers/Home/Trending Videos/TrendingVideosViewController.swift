//
//  TrendingVideosViewController.swift
//  Portal
//
//  Created by Stendy Antonio on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class TrendingVideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var postList : [Post] = []
    @IBOutlet weak var collectionViewTrending: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Trending"
        showNavigationBar()
        setList()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    func setList(){
          showIndicator()
          Post.all(result: { (posts) in
              self.postList = posts!
            self.postList.sort { (a, b) -> Bool in
                a.lpm! > b.lpm!
                      }
              DispatchQueue.main.async {
                  self.collectionViewTrending.reloadData()
                  self.hideIndicator()
              }
          }) { (error) in
              print(error)
          }
      }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrendingCollectionViewCell
        
            let post = postList[indexPath.row]
            cell.AudienceCount.text = "\(post.lpm ?? 0)"
            cell.CaptionLabel.text = post.title
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
