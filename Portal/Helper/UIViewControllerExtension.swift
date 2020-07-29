//
//  UIViewControllerExtension.swift
//  Portal
//
//  Created by Azam Mukhtar on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setNavBar(title: String){
        self.title = title
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2196078431, green: 0.3647058824, blue: 0.6666666667, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }

}
