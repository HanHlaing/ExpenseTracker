//
//  HomeViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import FirebaseAuth
import Firebase
import Foundation

class HomeViewController: UIViewController, MyDataSendingDelegateProtocol, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlets
    @IBOutlet weak var balanceDisplay: UILabel!
    @IBOutlet weak var incomeDisplay: UILabel!
    @IBOutlet weak var expenseDisplay: UILabel!
    @IBOutlet weak var transactionDataTableView: UITableView!
    
    
    @IBOutlet weak var btnAddTransaction: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    var segment: UISegmentedControl!
    var empty = [String]()
    var now = Foundation.Date()
    
    // MARK: Variables
    var transactionDataArr = [Transaction]()
    let ref = Database.database().reference(withPath:"transactions").child("DZIGIY2mpYdVVRyGcBmZGEnzRHm1") // firebase

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = tabBarController as! RaisedTabBarViewController
        segment = UISegmentedControl(items: ["Week", "Month", "Year"])
        segment.sizeToFit()
        segment.tintColor = #colorLiteral(red: 0, green: 0.007843137255, blue: 0.1450980392, alpha: 1)
        segment.selectedSegmentIndex = tabBar.selectedSegment
//        segment.frame = CGRect(x: 0, y: 0, width: 250, height: 10)
        switch (UIDevice().type) {
        case .iPhoneX, .iPhone6, .iPhone6S, .iPhone7, .iPhone8: //big screen iPhones
            segment.frame = CGRect(x: 0, y: 0, width: 220, height: 10)
        case .iPod4, .iPod5, .iPhone4, .iPhone4S, .iPhone5, .iPhone5S, .iPhoneSE: //small screen iPhones
            segment.frame = CGRect(x: 0, y: 0, width: 180, height: 10)//se
        default: //plus iPhones
            segment.frame = CGRect(x: 0, y: 0, width: 260, height: 10)
        }
        
        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Avenir Next", size: 15)!], for: .normal)
        self.navigationItem.titleView = segment
        segment.addTarget(self, action: #selector(changeSegment(sender:)), for: .valueChanged)
        
        
        
        // initialize balance on first day of month
        if Calendar.current.component(.day, from: Date()) == 1 {
            initBalance()
        }
        
        // calculate current balance
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "incomeBalance") - UserDefaults.standard.integer(forKey: "expenseBalance"), forKey: "currentBalance")
        
        // display balance
        balanceDisplay.text = "$" + String(UserDefaults.standard.integer(forKey: "currentBalance"))
        expenseDisplay.text = "$" + String( UserDefaults.standard.integer(forKey: "expenseBalance"))
        incomeDisplay.text = "$" + String(UserDefaults.standard.integer(forKey: "incomeBalance"))
        
        //currentDate.text = formatter.string(from: date)
        
        // display table
        transactionDataTableView.delegate = self
        transactionDataTableView.dataSource = self
        
        transactionDataTableView.register(UINib(nibName: "transactionDataTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionDataTableViewCell")
        
        let start = Int(tabBar.now.startOfMonth!.timeIntervalSince1970 * 1000)
        let end = Int(tabBar.now.endOfMonth!.timeIntervalSince1970 * 1000)
        loadData(start,end)
        // Do any additional setup after loading the view.
    }
        
    func loadData(_ start: Int, _ end: Int){
        // synchronize data to table view from firebase
        ref.queryOrdered(byChild: "transDate").queryStarting(atValue: start).queryEnding(atValue:end).observe( .value, with: { snapshot in
          var newItems: [Transaction] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
               let nestedItem = Transaction(snapshot:snapshot){
                
                newItems.append(nestedItem)
            }
          }
            self.transactionDataArr = newItems
            self.transactionDataTableView.reloadData()
            
            let filteredIncome = self.transactionDataArr.filter( {$0.transType == "income"} )
            let amountArr = filteredIncome.map( {Int($0.amount)! })
            let totalIncome = String(amountArr.reduce(0, +))
            self.incomeDisplay.text = "$" + totalIncome
            
            
            let filteredExpense = self.transactionDataArr.filter( {$0.transType == "expense"} )
            let amountArr1 = filteredExpense.map( {Int($0.amount)! })
            let totalExpense = String(amountArr1.reduce(0, +))
            self.expenseDisplay.text = "$" + totalExpense
            
            let currentBalance = String(Int(totalIncome)! - Int(totalExpense)!)
            self.balanceDisplay.text = "$" + currentBalance
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar = tabBarController as! RaisedTabBarViewController
       
        switch tabBar.selectedSegment {
        case 0:
            segment.selectedSegmentIndex = 0
            dateLbl.text = "\(tabBar.currentStartWeek!) - \(tabBar.currentEndWeek!)"
        case 1:
            segment.selectedSegmentIndex = 1
            dateLbl.text = tabBar.currentMonth
        default:
            segment.selectedSegmentIndex = 2
            dateLbl.text = tabBar.currentYear
        }
    }
    
    
    @IBAction func backwardBtnWasPressed(_ sender: Any) {
        
        dateLbl.rightTransition(0.2)
        let tabBar = tabBarController as! RaisedTabBarViewController
        changeDate(sender as! UIButton, currentDate: tabBar.now, segment: tabBar.selectedSegment, tab: tabBar)
        
        switch tabBar.selectedSegment {
        case 0:
            tabBar.now = tabBar.now.subtract(days: 7)
        case 1:
            tabBar.now = tabBar.now.subtract(months: 1)
        case 2:
            tabBar.now = tabBar.now.subtract(years: 1)
        default:
            break
        }
        
    }
    
    
    @IBAction func forwardBtnWasPressed(_ sender: Any) {
        
        dateLbl.leftTransition(0.2)
        let tabBar = tabBarController as! RaisedTabBarViewController
        changeDate(sender as! UIButton, currentDate: tabBar.now, segment: tabBar.selectedSegment, tab: tabBar)
        
        switch tabBar.selectedSegment {
        case 0:
            tabBar.now = tabBar.now.add(days: 7)
        case 1:
            tabBar.now = tabBar.now.add(months: 1)
        case 2:
            tabBar.now = tabBar.now.add(years: 1)
        default:
            break
        }

    }
    
    @objc func changeSegment(sender: UISegmentedControl) {
        
        now = Foundation.Date()
        let tabBar = tabBarController as! RaisedTabBarViewController
        tabBar.now = now
        
        switch sender.selectedSegmentIndex {
        case 0:
            let startWeek = now.startOfWeek
            let endWeek = now.endOfWeek
            tabBar.currentStartWeek = startWeek?.convertDateToString()
            tabBar.currentEndWeek = endWeek?.convertDateToString()
            tabBar.selectedSegment = 0
            dateLbl.text = "\(tabBar.currentStartWeek!) - \(tabBar.currentEndWeek!)"
            loadData(Int(startWeek!.timeIntervalSince1970 * 1000), Int(endWeek!.timeIntervalSince1970 * 1000) )
        case 1:
            let startMonth = now.startOfMonth
            let endMonth = now.endOfMonth
            
            tabBar.currentMonth = startMonth?.getMonthName()
            tabBar.selectedSegment = 1
            dateLbl.text = tabBar.currentMonth
            loadData(Int(startMonth!.timeIntervalSince1970 * 1000), Int(endMonth!.timeIntervalSince1970 * 1000) )
        default:
            let startOfYear = now.startOfYear
            let endOfYear = now.endOfYear
            
            tabBar.currentYear = startOfYear?.getYear()
            tabBar.selectedSegment = 2
            dateLbl.text = tabBar.currentYear
            loadData(Int(startOfYear!.timeIntervalSince1970 * 1000), Int(endOfYear!.timeIntervalSince1970 * 1000) )
        }
    
    }
    
    func changeDate(_ sender: UIButton, currentDate: Foundation.Date, segment: Int, tab: RaisedTabBarViewController) {
       
        var start: Foundation.Date
        var end: Foundation.Date
        var nextStart: Foundation.Date
        var nextEnd: Foundation.Date
        
        start = currentDate.startOfMonth!
        end = currentDate.endOfMonth!
        nextStart = start.add(months: 1)
        nextEnd = end.add(months: 1)
        
        switch segment {
        case 0:
            start = currentDate.startOfWeek!
            end = currentDate.endOfWeek!
            if(sender == forwardBtn) {
                nextStart = start.add(days: 7)
                nextEnd = end.add(days: 7)
            } else {
                nextStart = start.subtract(days: 7)
                nextEnd = end.subtract(days: 7)
            }
            
            let nextStartString = nextStart.convertDateToString()
            let nextEndString = nextEnd.convertDateToString()
            
            tab.currentStartWeek = nextStartString
            tab.currentEndWeek = nextEndString
            
            if (nextEnd.getYear() != Foundation.Date().getYear()) {
                dateLbl.text = "\(tab.currentStartWeek!) - \(tab.currentEndWeek!), '\(nextStart.getYearInShortFormat())"
            } else {
                dateLbl.text = "\(tab.currentStartWeek!) - \(tab.currentEndWeek!)"
            }
        case 1:
            start = currentDate.startOfMonth!
            end = currentDate.endOfMonth!
            if (sender == forwardBtn) {
                nextStart = start.add(months: 1)
                nextEnd = end.add(months: 1)
            } else {
                nextStart = start.subtract(months: 1)
                nextEnd = end.subtract(months: 1)
            }
            
            tab.currentMonth = nextStart.getMonthName()
            
            if (nextStart.getYear() != Foundation.Date().getYear()) {
                dateLbl.text = tab.currentMonth! + " " + (nextStart.getYear())
            } else {
                dateLbl.text = tab.currentMonth
            }
        case 2:
            start = currentDate.startOfYear!
            end = currentDate.endOfYear!
            
            if(sender == forwardBtn) {
                nextStart = start.add(years: 1)
                nextEnd = end.add(years: 1)
            } else {
                nextStart = start.subtract(years: 1)
                nextEnd = end.subtract(years: 1)
            }
            
            tab.currentYear = nextStart.getYear()
            
            dateLbl.text = tab.currentYear
        default:
            break
        }
        
        let startTime = Int(nextStart.timeIntervalSince1970 * 1000)
        let endTime = Int(nextEnd.timeIntervalSince1970 * 1000)
        
        loadData(startTime, endTime )
    
    }
    
    
    // initialze balance and store to monthlyData table
    func initBalance(){
   
        // initialize current month balance
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "currentBalance")
        defaults.set(0, forKey: "expenseBalance")
        defaults.set(0, forKey: "incomeBalance")
    }
    
    // update expense
    func updateExpense(date: String, expenseAmount: String, notes: String, category: String,transDate: Int, transType: String) {
        let updatedExpense:Int = Int(expenseAmount)! + UserDefaults.standard.integer(forKey: "expenseBalance")
        UserDefaults.standard.set(updatedExpense, forKey: "expenseBalance")
        // add entry to table
        
        
        let item = Transaction(date: date, amount:  expenseAmount, notes: notes, category: category,transDate: transDate, transType: transType)
        let itemRef = self.ref.childByAutoId()//.child("expense")
        itemRef.setValue(item.toAnyObject())
        
        // transactionDataArr.append(TransactionItem(date: transDate, amount: "-¥" + expenseAmount))
        // transactionDataTableView.reloadData()
        
        viewDidLoad()
        
    }
    
    // update income
    func updateIncome(date: String, incomeAmount: String, notes: String, category: String, transDate: Int, transType: String) {
        let updatedIncome: Int = Int(incomeAmount)! + UserDefaults.standard.integer(forKey: "incomeBalance")
        UserDefaults.standard.set(updatedIncome, forKey: "incomeBalance")
        // add entry to table
        
        
        let item = Transaction(date: date, amount: incomeAmount, notes: notes, category: category,transDate: transDate,transType: transType)
        let itemRef = self.ref.childByAutoId()//.child("income")
        itemRef.setValue(item.toAnyObject())
        
        // transactionDataArr.append(TransactionItem(date: transDate, amount: "+¥" + incomeAmount))
        // transactionDataTableView.reloadData()
        
        viewDidLoad()
    }

    // UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactionDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionDataTableViewCell", for: indexPath) as! transactionDataTableViewCell
        cell.dateCell.text = transactionDataArr[indexPath.row].date
        cell.categoryCell.text = transactionDataArr[indexPath.row].category
        cell.amountCell.text = (transactionDataArr[indexPath.row].transType == "income" ? "+ ": "- ") + "$" + transactionDataArr[indexPath.row].amount
        
        if transactionDataArr[indexPath.row].notes.isEmpty == true {
            cell.notesCell.text = transactionDataArr[indexPath.row].category
        }
        else {
            cell.notesCell.text = transactionDataArr[indexPath.row].notes
        }
        return cell
    }
    
    // segue
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "addInput" {
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController as! AddTransactionViewController
           targetController.delegate = self
       }
   }
    
}