//
//  AppDelegate.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 15/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().barTintColor = UIColor.init(named: "ColorBlue")
        UINavigationBar.appearance().tintColor =  UIColor.init(named: "ColorYellow")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    static func relaunchMain(selectedIndex: Int? = 0, duration: Double? = 0.24, completion: ((Bool) -> (Void))?) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.rootViewController?.navigationController?.popToRootViewController(animated: false)
        
        if window.rootViewController is MainTabBarController && window.rootViewController?.navigationController != nil {
            window.backgroundColor = UIColor.black
            window.alpha = 0.5
            
            let mainTabBarViewController = window.rootViewController as! MainTabBarController
            mainTabBarViewController.selectedIndex = selectedIndex ?? 0
            
            UIView.transition(with: window, duration: duration ?? 0.24, options: .transitionCrossDissolve, animations: {
                window.alpha = 1.0
            }, completion: { completed in
                completion?(completed)
            })
            
            return
        }
        
        window.rootViewController?.navigationController?.popToRootViewController(animated: true)
        window.rootViewController?.dismiss(animated: false, completion: nil)
        
        window.rootViewController = nil
        window.rootViewController?.view = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        controller.selectedIndex = selectedIndex ?? 0
        
        window.backgroundColor = UIColor.black
        window.alpha = 0.0
        window.rootViewController = controller
        
        UIView.transition(with: window, duration: duration ?? 0.24, options: .transitionCrossDissolve, animations: {
            window.alpha = 1.0
        }, completion: { completed in
            completion?(completed)
        })
        
    }

}

public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
