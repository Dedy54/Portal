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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    }
    
    override var selectedIndex: Int {
        didSet {
            super.selectedIndex = selectedIndex
        }
    }
    
}
