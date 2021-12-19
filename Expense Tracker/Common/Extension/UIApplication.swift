//
//  UIApplication.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit

extension UIApplication {
    
    public static func setRootView(_ viewController: UIViewController,
                                   options: UIView.AnimationOptions = .transitionCrossDissolve,
                                   animated: Bool = true,
                                   duration: TimeInterval = 0.5,
                                   completion: (() -> Void)? = nil) {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        guard animated else {
            keyWindow?.rootViewController = viewController
            return
        }
        
        keyWindow?.rootViewController = viewController
        UIView.transition(with: keyWindow!, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            keyWindow?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
}
