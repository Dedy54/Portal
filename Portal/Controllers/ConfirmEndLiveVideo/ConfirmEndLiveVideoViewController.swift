//
//  ConfirmEndLiveVideoViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 07/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

protocol ConfirmEndLiveVideoViewControllerDelegate {
    func didCancelEndLiveVideo()
    func didEndLiveVideo()
}

class ConfirmEndLiveVideoViewController: UIViewController {

    var confirmEndLiveVideoViewControllerDelegate: ConfirmEndLiveVideoViewControllerDelegate?
    
    @IBOutlet weak var endLiveButton: UIButton!{
        didSet{
            endLiveButton.layer.cornerRadius = 5
        }
    }
    @IBAction func actionEndNow(_ sender: Any) {
        confirmEndLiveVideoViewControllerDelegate?.didEndLiveVideo()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var cancelEndButton: UIButton!{
        didSet{
            cancelEndButton.layer.cornerRadius = 5
        }
    }
    @IBAction func actionCancelEndNow(_ sender: Any) {
        confirmEndLiveVideoViewControllerDelegate?.didCancelEndLiveVideo()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
//        view.alpha = 0.0
    }
}
