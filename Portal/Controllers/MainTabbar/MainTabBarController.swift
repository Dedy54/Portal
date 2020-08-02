//
//  MainTabBarController.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        overrideUserInterfaceStyle = .dark
        
        
        //        print(PreferenceManager.instance.isUserLogin)
        //        print(PreferenceManager.instance.userEmail)?\
        //        print(PreferenceManager.instance.userId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title {
        case "Open Mic":
            print("Open Mic")
            if PreferenceManager.instance.isUserLogin == false {
                let storyboard = UIStoryboard(name: "Register", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                controller.navigationController?.isNavigationBarHidden = true
                self.present(controller, animated:true, completion: {
                    self.selectedIndex = 0
                })
            } else {
                self.showIndicator()
                let storyboard = UIStoryboard(name: "LiveMenu", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LiveMenuViewController") as! LiveMenuViewController
                controller.hidesBottomBarWhenPushed = true
                controller.modalPresentationStyle = .fullScreen
                let navigationController = UINavigationController(rootViewController: controller)
                navigationController.modalPresentationStyle = .overCurrentContext
                self.present(navigationController, animated: true) {
                    self.hideIndicator()
                    self.selectedIndex = 0
                }
            }
        case "Profile":
            if PreferenceManager.instance.isUserLogin == false {
                performSegue(withIdentifier: "toRegister", sender: nil)
                self.selectedIndex = 0
            }
        case "Notification":
            if PreferenceManager.instance.isUserLogin == false {
                performSegue(withIdentifier: "toRegister", sender: nil)
                self.selectedIndex = 0
                
            }
        default:
            print(item.title)
        }
        
    }
    
    override var selectedIndex: Int {
        didSet {
            super.selectedIndex = selectedIndex
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        if PreferenceManager.instance.isUserLogin == false {
        //            self.selectedIndex = 1
        //        }
    }
    
    
}
