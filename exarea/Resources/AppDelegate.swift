//
//  AppDelegate.swift
//  exarea
//
//  Created by Soroush on 7/4/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import UIKit
import SideMenu
import KeychainAccess
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SideMenuManager.default.menuPresentMode = .viewSlideOut
        if !UserDefaults.standard.bool(forKey: "clearedKeychain") {
            Account.clearKeychain()
            UserDefaults.standard.set(true, forKey: "clearedKeychain")
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        return true
    }

}

