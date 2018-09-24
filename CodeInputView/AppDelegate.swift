//
//  AppDelegate.swift
//  CodeInputView
//
//  Created by Milos Dimic on 9/21/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let mainViewController = MainViewController()
        
        window?.rootViewController = mainViewController
        
        return true
    } 
}

