//
//  ViewController.swift
//  Portal
//
//  Created by Evan Renanto on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PreferenceManager.instance.finishedOnboarding == false {
            performSegue(withIdentifier: "toOnBoardingPage", sender: self)
        }
        else {
            performSegue(withIdentifier: "toMainTabBarPage", sender: self)
        }


    }


}
