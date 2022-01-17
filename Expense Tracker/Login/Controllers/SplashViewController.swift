//
//  SplashViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 21/12/2021.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {

    var _authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listen authentication changes to route specific screen
        _authHandle = Auth.auth().addStateDidChangeListener() { auth, user in
                if user != nil {
                    // Show home page
                    UserManager.shared.userID = user?.uid
                    let homeVC = RaisedTabBarViewController.instantiate(from: .Home)
                    UIApplication.shared.windows.first?.rootViewController = homeVC
                } else {
                    // Show login page
                    let loginVC = SigninViewController.instantiate(from: .Login)
                    UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: loginVC)
                }
            }
    }
    
    deinit {
        
        if _authHandle != nil {
            Auth.auth().removeStateDidChangeListener(_authHandle)
        }
    }
}
