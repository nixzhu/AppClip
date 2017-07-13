//
//  AppDelegate.swift
//  IcePack
//
//  Created by nixzhu on 2017/7/13.
//  Copyright © 2017年 nixWork. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("open url: \(url)")
        guard let tabVC = window?.rootViewController as? UITabBarController else { return false }
        switch url.lastPathComponent {
        case "tab1":
            tabVC.selectedIndex = 0
        case "tab2":
            tabVC.selectedIndex = 1
        default:
            break
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }
}
