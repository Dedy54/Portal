//
//  ChooseSaveLiveVideoViewController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 07/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

protocol ChooseSaveLiveVideoViewControllerDelegate {
    func didActionSavePress()
    func didActionDownloadPress()
    func didActionDeletePress()
}

class ChooseSaveLiveVideoViewController: UIViewController {
    
    @IBAction func actionSaveLivePost(_ sender: Any) {
        self.showIndicator()
        self.delay(3) {
            self.hideIndicator()
            let alert = UIAlertController(title: "Success", message: "Saved to Post", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.chooseSaveLiveVideoViewControllerDelegate?.didActionSavePress()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
    }

    @IBAction func actionDownloadLivePost(_ sender: Any) {
        self.showIndicator()
        self.delay(3) {
            self.hideIndicator()
            let alert = UIAlertController(title: "Success", message: "Live video saved in Photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.chooseSaveLiveVideoViewControllerDelegate?.didActionDownloadPress()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
    }

    @IBAction func actionDeleteLivePost(_ sender: Any) {
        self.showIndicator()
        self.delay(3) {
            self.hideIndicator()
            let alert = UIAlertController(title: "Success", message: "Delete live video success", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.chooseSaveLiveVideoViewControllerDelegate?.didActionDeletePress()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
    }
    
    var chooseSaveLiveVideoViewControllerDelegate : ChooseSaveLiveVideoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationBar()
    }

}
