//
//  UIViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import Foundation
import UIKit

extension UIViewController {
    
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(from: AppStoryboard) -> Self {
        return from.viewController(viewControllerClass: self)
    }
    
    // Display Error Message to the User
    func showErrorAlert(_ title: String, _ messageBody: String) {
        
        let alertVC = UIAlertController(title: title, message: messageBody, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //show can't be used in navigation controller
        present(alertVC, animated: true, completion: nil)
    }
}

extension UITextField {
    func addDepth() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.white.cgColor
        self.borderStyle = .roundedRect
    }
}

extension UIButton {
    func makecoloredButton() {
        self.layer.shadowColor = #colorLiteral(red: 0.3699039817, green: 0.7330554724, blue: 0.9979006648, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 10
    }
    
    func makeCircularButton() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
}

extension UIView {
    func leftTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromRight
        animation.duration = duration
        layer.add(animation, forKey: kCATransition)
    }
    
    func rightTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromLeft
        animation.duration = duration
        layer.add(animation, forKey: kCATransition)
    }
}
