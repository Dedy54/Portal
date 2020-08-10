//
//  NewPostFormViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AVFoundation

protocol NewPostFormViewControllerDelegate {
    func didSuccessPost()
}

class NewPostFormViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!{
        didSet{
            self.postImageView.clipsToBounds = true
            self.postImageView.layer.cornerRadius = 10
            self.postImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var counterTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBAction func actionSwitch(_ sender: Any) {
        self.post?.isSensitiveContent = sensitivitySwitch.isOn ? 1 : 0
    }
    @IBOutlet weak var sensitivitySwitch: UISwitch!{
        didSet{
            sensitivitySwitch.isOn = false
        }
    }
    
    var post : Post?
    var newPostFormViewControllerDelegate : NewPostFormViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.delegate = self
        self.title = "New Post"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(addTappedPost))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backPost))
        
        self.setView(post: self.post)
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func backPost(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "All changes will be discarded.\nContinue ?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in }))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (alert) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    @objc func addTappedPost(sender: UIBarButtonItem) {
        if let post = post, let videoUrl = post.videoUrl {
            self.titleTextField.endEditing(true)
            let title = titleTextField.text ?? ""
            let email = PreferenceManager.instance.userEmail
            
            self.post?.title = title
            self.post?.isSensitiveContent = self.sensitivitySwitch.isOn ? 1 : 0
            self.showIndicator()
            
            Post(title: title, viewer: post.viewer, lpm: post.lpm, videoUrl: videoUrl, isSensitiveContent: post.isSensitiveContent, isLive: post.isLive, userReference: post.userReference, email: email).save(result: { (result) in
                DispatchQueue.main.async {
                    self.hideIndicator()
                    self.newPostFormViewControllerDelegate?.didSuccessPost()
                    self.navigationController?.dismiss(animated: true, completion: {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                }
            }, errorCase: { (error) in
                DispatchQueue.main.async {
                    self.hideIndicator()
                }
            })
            
            
        }
    }
    
    func setView(post: Post?){
        if let post = post {
            post.getThumbnail(completion: { (thumbnailImage) in
                self.postImageView.image = thumbnailImage
            })
        }
    }
    
}

extension NewPostFormViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let MAX_LENGTH = 120
        let updatedString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        self.counterTitleLabel.text = "\(updatedString.count)/120"
        return updatedString.count < MAX_LENGTH
    }
}
