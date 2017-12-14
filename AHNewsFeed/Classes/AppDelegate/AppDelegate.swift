//
//  AppDelegate.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        startApplication()
        
        return true
    }
}

//MARK: - Private Methods -
extension AppDelegate {
    
    fileprivate func startApplication() {

        // configurate application apperance
        UIHelper.configurateApplicationApperance()
        
        // config root view controller
        configRootViewController()
    }
    
    fileprivate func configRootViewController() {
        let root = UINavigationController(rootViewController: LandingViewController())
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
    }
}


