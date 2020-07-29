//
//  NewPostFormViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AVFoundation

class NewPostFormViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var counterTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBAction func actionSwitch(_ sender: Any) {
        self.post?.isSensitiveContent = sensitivitySwitch.isOn
    }
    @IBOutlet weak var sensitivitySwitch: UISwitch!{
        didSet{
            sensitivitySwitch.isOn = false
        }
    }
    
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(addTappedPost))
        self.hideKeyboardWhenTappedAround()
        self.setView(post: self.post)
    }
    
    @objc func addTappedPost(sender: UIBarButtonItem) {
        let title = titleTextField.text
        self.post?.title = title
    }
    
    func setView(post: Post?){
        if let post = post, let videoUrl = post.videoUrl {
            self.getThumbnailImageFromVideoUrl(url: videoUrl) { (thumbnailImage) in
                self.postImageView.image = thumbnailImage
            }
        }
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

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
