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
            if PreferenceManager.instance.isUserLogin == false {
//                performSegue(withIdentifier: "toRegister", sender: nil)
//                self.selectedIndex = 0
                
                AppDelegate.relaunchMain(selectedIndex: self.selectedIndex, duration: 0.0) { (result) -> (Void) in
                    if let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController {
                        let storyboard = UIStoryboard(name: "Register", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                        controller.navigationController?.isNavigationBarHidden = true
//                        controller.hidesBottomBarWhenPushed = true
//                        visibleViewController.navigationController?.pushViewController(controller, animated: true)
//                        let navController = UINavigationController(rootViewController: controller)
                        visibleViewController.present(controller, animated:true, completion: nil)
                    }
                }
            } else {
                AppDelegate.relaunchMain(selectedIndex: self.selectedIndex, duration: 0.0) { (result) -> (Void) in
                    if let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController {
                        let storyboard = UIStoryboard(name: "LiveMenu", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "LiveMenuViewController") as! LiveMenuViewController
                        controller.hidesBottomBarWhenPushed = true
                        visibleViewController.navigationController?.pushViewController(controller, animated: true)
                    }
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
