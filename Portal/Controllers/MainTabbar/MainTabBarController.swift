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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Open Mic" {
            if !PreferenceManager.instance.isUserLogin {
                AppDelegate.relaunchMain(selectedIndex: self.selectedIndex, duration: 0.0) { (result) -> (Void) in
                    if let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController {
                        let storyboard = UIStoryboard(name: "LiveMenu", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "LiveMenuViewController") as! LiveMenuViewController
                        controller.hidesBottomBarWhenPushed = true
                        visibleViewController.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            super.selectedIndex = selectedIndex
        }
    }
    
}
