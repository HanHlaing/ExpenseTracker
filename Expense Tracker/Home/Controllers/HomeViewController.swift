//
//  HomeViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import Firebase
import Foundation

class HomeViewController: UIViewController, MyDataSendingDelegateProtocol, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var balanceDisplay: UILabel!
    @IBOutlet weak var incomeDisplay: UILabel!
    @IBOutlet weak var expenseDisplay: UILabel!
    @IBOutlet weak var transactionDataTableView: UITableView!
    
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    // MARK: Variables
    var selectedIndex = 0
    var segment: UISegmentedControl!
    var empty = [String]()
    var now = Foundation.Date()
    var transactionDataArr = [Transaction]()
    var _refHandle: DatabaseHandle!
    let ref = Database.database().reference(withPath:"transactions").child(UserManager.shared.userID!) // firebase
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = tabBarController as! RaisedTabBarViewController
        segment = UISegmentedControl(items: ["Week", "Month", "Year"])
        segment.sizeToFit()
        segment.tintColor = #colorLiteral(red: 0, green: 0.007843137255, blue: 0.1450980392, alpha: 1)
        segment.selectedSegmentIndex = tabBar.selectedSegment
      
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
        
        // display table
        transactionDataTableView.delegate = self
        transactionDataTableView.dataSource = self
        
        transactionDataTableView.register(UINib(nibName: "transactionDataTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionDataTableViewCell")
        
        let start = Int(tabBar.now.startOfMonth!.timeIntervalSince1970 * 1000)
        let end = Int(tabBar.now.endOfMonth!.timeIntervalSince1970 * 1000)
        loadTransactions(start,end)
        // Do any additional setup after loading the view.
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
    
    deinit {
        if let refHandle = _refHandle {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    //MARK: - Actions
    @IBAction func addTransaction(_ sender: Any) {
        
        selectedIndex = -1
        performSegue(withIdentifier: "addInput", sender: nil)
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
    
    //MARK: - Private Methods
    
    func loadTransactions(_ start: Int, _ end: Int) {
        
        // synchronize data to table view from firebase
        _refHandle = ref.queryOrdered(byChild: "transDate").queryStarting(atValue: start).queryEnding(atValue:end).observe( .value, with: { snapshot in
            var newItems: [Transaction] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let nestedItem = Transaction(snapshot:snapshot){
                    
                    newItems.append(nestedItem)
                }
            }
            self.transactionDataArr = newItems.reversed()
            self.transactionDataTableView.reloadData()
            
            let filteredIncome = self.transactionDataArr.filter( {$0.transType == "income"} )
            let amountArr = filteredIncome.map( {Double($0.amount)! })
            //let totalIncome = amountArr.reduce(0, +).clean
            let income = amountArr.reduce(0, +)
            self.incomeDisplay.text = income.clean
            
            
            let filteredExpense = self.transactionDataArr.filter( {$0.transType == "expense"} )
            let amountArr1 = filteredExpense.map( {Double($0.amount)! })
            let expense = amountArr1.reduce(0, +)
            self.expenseDisplay.text = expense.clean
            
            let currentBalance = Double(income - expense).clean
            self.balanceDisplay.text = currentBalance
        })
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
            loadTransactions(Int(startWeek!.timeIntervalSince1970 * 1000), Int(endWeek!.timeIntervalSince1970 * 1000) )
        case 1:
            let startMonth = now.startOfMonth
            let endMonth = now.endOfMonth
            
            tabBar.currentMonth = startMonth?.getMonthName()
            tabBar.selectedSegment = 1
            dateLbl.text = tabBar.currentMonth
            loadTransactions(Int(startMonth!.timeIntervalSince1970 * 1000), Int(endMonth!.timeIntervalSince1970 * 1000) )
        default:
            let startOfYear = now.startOfYear
            let endOfYear = now.endOfYear
            
            tabBar.currentYear = startOfYear?.getYear()
            tabBar.selectedSegment = 2
            dateLbl.text = tabBar.currentYear
            loadTransactions(Int(startOfYear!.timeIntervalSince1970 * 1000), Int(endOfYear!.timeIntervalSince1970 * 1000) )
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
        
        loadTransactions(startTime, endTime )
        
    }
    
    // add expense/income transaction
    func addTransaction(date: String, amount: String, notes: String, category: String,transDate: Int, transType: String) {
    
        // add entry to table
        let item = Transaction(date: date, amount:  amount, notes: notes, category: category,transDate: transDate, transType: transType)
        let itemRef = self.ref.childByAutoId()
        itemRef.setValue(item.toAnyObject())
        
        viewDidLoad()
    }
    
    // update expense/income transaction
    func updateTransaction(transaction: Transaction) {
        
        transaction.ref?.updateChildValues(["date": transaction.date,
                                                  "amount": transaction.amount,
                                                  "notes": transaction.notes,
                                                  "category": transaction.category,
                                                  "transDate": transaction.transDate,
                                                  "transType": transaction.transType])
    }
    
    //MARK: - Delegate methods
    
    // UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactionDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionDataTableViewCell", for: indexPath) as! transactionDataTableViewCell
        cell.dateCell.text = transactionDataArr[indexPath.row].date
        cell.categoryCell.text = transactionDataArr[indexPath.row].category
        cell.amountCell.text = (transactionDataArr[indexPath.row].transType == "income" ? "+ ": "- ") + transactionDataArr[indexPath.row].amount
        
        if transactionDataArr[indexPath.row].notes.isEmpty == true {
            cell.notesCell.text = transactionDataArr[indexPath.row].category
        }
        else {
            cell.notesCell.text = transactionDataArr[indexPath.row].notes
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "addInput", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            transactionDataArr[indexPath.row].ref?.removeValue()
            transactionDataArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addInput" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! AddTransactionViewController
            targetController.delegate = self
            if selectedIndex != -1 {
                targetController.transaction = transactionDataArr[selectedIndex]
            }
        }
    }
    
}
