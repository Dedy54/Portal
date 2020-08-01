//
//  PreferenceManager.swift
//  Portal
//
//  Created by Dedy Yuristiawan on 12/05/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation

class PreferenceManager: NSObject {
    
    private static let FinishedOnboarding = "finished_onboarding"
    private static let IsUserLogin = "is_user_login"
    private static let UserName = "user_name"
    private static let UserEmail = "user_email"
    private static let UserID = "user_id"
    
    static let instance = PreferenceManager()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var finishedOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: PreferenceManager.FinishedOnboarding)
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: PreferenceManager.FinishedOnboarding)
        }
    }
    
    var isUserLogin: Bool {
        get {
            return userDefaults.bool(forKey: PreferenceManager.IsUserLogin)
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: PreferenceManager.IsUserLogin)
        }
    }
    
    var userEmail: String? {
        get {
            return userDefaults.string(forKey: PreferenceManager.UserEmail)
        }
        set(newValue) {
            if let value = newValue {
                userDefaults.set(value, forKey: PreferenceManager.UserEmail)
            }else {
                userDefaults.removeObject(forKey:PreferenceManager.UserEmail)
            }
        }
    }
    
    var userName: String? {
        get {
            return userDefaults.string(forKey: PreferenceManager.UserName)
        }
        set(newValue) {
            if let value = newValue {
                userDefaults.set(value, forKey: PreferenceManager.UserName)
            }else {
                userDefaults.removeObject(forKey:PreferenceManager.UserName)
            }
        }
    }
    
    var userId: String? {
        get {
            return userDefaults.string(forKey: PreferenceManager.UserID)
        }
        set(newValue) {
            if let value = newValue {
                userDefaults.set(value, forKey: PreferenceManager.UserID)
            }else {
                userDefaults.removeObject(forKey:PreferenceManager.UserID)
            }
        }
    }
    
}
