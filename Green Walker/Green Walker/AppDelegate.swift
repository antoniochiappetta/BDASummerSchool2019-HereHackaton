//
//  AppDelegate.swift
//  Green Walker
//
//  Created by Antonio Chiappetta on 06/08/2019.
//  Copyright © 2019 Group 5 BDASummerSchool 2019. All rights reserved.
//

import UIKit

import NMAKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - NMA Setup
        
        NMAApplicationContext.set(appId: "K9gdtjFfOYhcutscXTr0",
                                  appCode: "AVv27j0WmWrWzSwZeWDTOA")
        
        return true
    }


}

