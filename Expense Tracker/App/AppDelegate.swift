//
//  AppDelegate.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Thread.sleep(forTimeInterval: 0.5)
        return true
    }
}

