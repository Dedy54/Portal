//
//  LiveNewViewController.swift
//  Portal
//
//  Created by Stendy Antonio on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class LiveNowViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionVIew: UICollectionView!{
        didSet{
            if let layout = collectionVIew.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
            }
        }
    }
    
    var liveRooms : [LiveRoom] = [LiveRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Live Now"
        self.showNavigationBar()
        self.refresh()
    }
    
    func refresh() {
        self.showIndicator()
        LiveRoom.all(result: { (result) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if let result = result {
                    self.liveRooms = result
                }
                self.collectionVIew.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.hideIndicator()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LiveNowCollectionViewCell
        cell.shadowDecorate()
        cell.liveRoom = self.liveRooms[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "StreamLiveVideo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "StreamLiveVideoViewController") as! StreamLiveVideoViewController
        controller.liveRoom = self.liveRooms[indexPath.row]
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}


extension LiveNowViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.collectionVIew == collectionView {
            let widthCard = (UIScreen.main.bounds.width - CGFloat((20 * 3))) / 2 // 20 margin center
            return CGSize(width: widthCard, height: 262)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 50.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
