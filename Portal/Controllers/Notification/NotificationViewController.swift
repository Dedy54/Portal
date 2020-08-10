//
//  NotificationViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var postList : [Post] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideNavigationBar()
    }
    
    func setList(){
           showIndicator()
            Post.all(result: { (posts) in
               self.postList = posts!
               DispatchQueue.main.async {
                   self.collectionView.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NotificationCollectionViewCell
        
        
        let post = postList[indexPath.row]
              cell.StandUpComedianName.text = "New video has been posted"
        cell.StandUpComedianActivity.text = "Title : \(post.title ?? "")"
              post.getThumbnailCloudKit(completion: { (thumbnailImage) in
                  cell.StandUpComedianPict.image = thumbnailImage
              })
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
          hideNavigationBar()
          setList()
      }
}
