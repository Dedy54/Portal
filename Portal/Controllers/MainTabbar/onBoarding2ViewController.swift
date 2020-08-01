//
//  onBoarding2ViewController.swift
//  Portal
//
//  Created by Evan Renanto on 23/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class onBoarding2ViewController: UIViewController {

    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goButton.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    

    @IBAction func changeOnBoardPref(_ sender: Any) {
        PreferenceManager.instance.finishedOnboarding = true
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
