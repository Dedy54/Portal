//
//  UIViewControllerExtension.swift
//  Portal
//
//  Created by Azam Mukhtar on 27/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

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

// Put this piece of code anywhere you like
extension UIViewController {
    func delay(_ delay:Double, closure:@escaping ()->()) {
         let when = DispatchTime.now() + delay
         DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
     }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    
   func showIndicator() {
      let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
      Indicator.isUserInteractionEnabled = false
      Indicator.show(animated: true)
   }
    
   func hideIndicator() {
      MBProgressHUD.hide(for: self.view, animated: true)
   }
}
