//
//  RaisedTabBarViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit

class RaisedTabBarViewController: UITabBarController {
    
    var selectedSegment: Int = 1
    
    var currentStartWeek: String?
    var currentEndWeek: String?
    var currentMonth: String?
    var currentYear: String?
    var startOfMonth: NSDate!
    var endOfMonth: NSDate!
    
    var now = Foundation.Date()
    
    var dateChanged: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startOfMonth = now.startOfMonth! as NSDate
        endOfMonth = now.endOfMonth! as NSDate
        
        currentMonth = now.getMonthName()
        currentYear = now.getYear()
        
        dateChanged = false
    }
    
    func insertEmptyClass(_ title: String, atIndex: Int) {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: 0)
        vc.tabBarItem.isEnabled = false
        
        self.viewControllers?.insert(vc, at: atIndex)
    }
    
    func addRaisedButton(_ buttonImage: UIImage?, highlightImage: UIImage?, offSet: CGFloat? = nil) {
        if let btnImg = buttonImage {
            let button = UIButton(type: .custom)
            button.autoresizingMask = [UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleTopMargin]
            
            button.frame = CGRect(x: 0.0, y: 0.0, width: btnImg.size.width, height: btnImg.size.height)
            button.setBackgroundImage(btnImg, for: UIControl.State())
            button.setBackgroundImage(highlightImage, for: UIControl.State.highlighted)
            
            let heightDifference = btnImg.size.height - self.tabBar.frame.size.height
            
            if (heightDifference < 0) {
                button.center = self.tabBar.center
            } else {
                var center = self.tabBar.center
                center.y -= heightDifference / 2.0
                button.center = center
            }
            
            if (offSet != nil) {
                var center = button.center
                center.y = center.y + offSet!
                button.center = center
            }
            
            button.addTarget(self, action: #selector(onRaisedButton(_:)), for: UIControl.Event.touchUpInside)
            self.view.addSubview(button)
        }
    }
    
    @objc func onRaisedButton(_ sender: UIButton!) {
        
    }

}
