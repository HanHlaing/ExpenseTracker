//
//  RaisedTabBarViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit
import Foundation

class RaisedTabBarViewController: UITabBarController {
    
    var selectedSegment: Int = 1
    var currentStartWeek: String?
    var currentEndWeek: String?
    var currentMonth: String?
    var currentYear: String?
    var startOfMonth: NSDate!
    var endOfMonth: NSDate!
    var start = 0
    var end = 0
    
    var now = Date()
    var dateChanged: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startOfMonth = now.startOfMonth! as NSDate
        endOfMonth = now.endOfMonth! as NSDate
        
        currentMonth = now.getMonthName()
        currentYear = "\(Calendar.current.component(.year, from: Date()))"
        
        // initialize start and end date of current month
        start = Int(startOfMonth.timeIntervalSince1970 * 1000)
        end = Int(endOfMonth.timeIntervalSince1970 * 1000)
        
        dateChanged = false
    }
}
