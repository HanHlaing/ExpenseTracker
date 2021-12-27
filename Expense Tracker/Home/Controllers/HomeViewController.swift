//
//  HomeViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import Firebase
import Foundation

class HomeViewController: UIViewController, MyDataSendingDelegateProtocol {
    
    // MARK: - Outlets
    
    @IBOutlet weak var balanceDisplayLabel: UILabel!
    @IBOutlet weak var incomeDisplayLabel: UILabel!
    @IBOutlet weak var expenseDisplayLabel: UILabel!
    @IBOutlet weak var noTransactionLabel: UILabel!
    @IBOutlet weak var transactionDataTableView: UITableView!
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    // MARK: - Variables
    
    var selectedIndex = -1 // set default -1 for new transaction
    var segment: UISegmentedControl!
    var now = Foundation.Date()
    var transactionDataArr = [Transaction]()
    var _refHandle: DatabaseHandle!
    let ref = Database.database().reference(withPath: FirebaseDatabase.transactions).child(UserManager.shared.userID!)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let tabBar = tabBarController as! RaisedTabBarViewController
        // set common date label to synchronize changes from chart view
        switch tabBar.selectedSegment {
        case 0:
            segment.selectedSegmentIndex = 0
            dateLabel.text = "\(tabBar.currentStartWeek!) - \(tabBar.currentEndWeek!)"
        case 1:
            segment.selectedSegmentIndex = 1
            dateLabel.text = tabBar.currentMonth
        default:
            segment.selectedSegmentIndex = 2
            dateLabel.text = tabBar.currentYear
        }
        // load transactions of current month and reload data to synchronize changes from chart view
        loadTransactions(tabBar.start,tabBar.end)
    }
    
    deinit {
        if let refHandle = _refHandle {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func addTransaction(_ sender: Any) {
        
        // set selected index to -1 for new transaction
        selectedIndex = -1
        performSegue(withIdentifier: Identifier.addTransaction, sender: nil)
    }
    
    @IBAction func backwardBtnWasPressed(_ sender: Any) {
        
        dateLabel.rightTransition(0.2)
        let tabBar = tabBarController as! RaisedTabBarViewController
        changeDate(sender as! UIButton, currentDate: tabBar.now, segment: tabBar.selectedSegment, tab: tabBar)
        
        switch tabBar.selectedSegment {
        case 0:// days
            tabBar.now = tabBar.now.subtract(days: 7)
        case 1:// month
            tabBar.now = tabBar.now.subtract(months: 1)
        case 2:// year
            tabBar.now = tabBar.now.subtract(years: 1)
        default:
            break
        }
        
    }
    
    @IBAction func forwardBtnWasPressed(_ sender: Any) {
        
        dateLabel.leftTransition(0.2)
        let tabBar = tabBarController as! RaisedTabBarViewController
        changeDate(sender as! UIButton, currentDate: tabBar.now, segment: tabBar.selectedSegment, tab: tabBar)
        
        switch tabBar.selectedSegment {
        case 0:// week
            tabBar.now = tabBar.now.add(days: 7)
        case 1:// month
            tabBar.now = tabBar.now.add(months: 1)
        case 2:// year
            tabBar.now = tabBar.now.add(years: 1)
        default:
            break
        }
        
    }
    
    //MARK: - Private Methods
    
    func configureUI() {
        
        // setup tab bar
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
        navigationItem.titleView = segment
        segment.addTarget(self, action: #selector(changeSegment(sender:)), for: .valueChanged)
        
        // display table
        transactionDataTableView.delegate = self
        transactionDataTableView.dataSource = self
        transactionDataTableView.register(UINib(nibName: Identifier.transactionViewCell, bundle: nil), forCellReuseIdentifier: Identifier.transactionViewCell)
        
    }
    
    // get transactions from firebase and show in table view
    func loadTransactions(_ start: Int, _ end: Int) {
        
        // synchronize data to table view from firebase by using transDate
        _refHandle = ref.queryOrdered(byChild: "transDate").queryStarting(atValue: start).queryEnding(atValue:end).observe( .value, with: { snapshot in
            
            var transactions: [Transaction] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let nestedItem = Transaction(snapshot:snapshot){
                    
                    transactions.append(nestedItem)
                }
            }
            
            if transactions.isEmpty {
                
                // reset default value when there is no transaction
                self.noTransactionLabel.isHidden = false
                self.noTransactionLabel.text = "Tap + to add transaction!"
                self.incomeDisplayLabel.text = "0"
                self.expenseDisplayLabel.text = "0"
                self.balanceDisplayLabel.text = "0"
            } else {
                
                self.noTransactionLabel.isHidden = true
                // sort desc order by date
                self.transactionDataArr = transactions.reversed()
                self.transactionDataTableView.reloadData()
                
                // calculate and show total income
                let filteredIncome = self.transactionDataArr.filter( {$0.transType == TransactionType.income} )
                let amountArr = filteredIncome.map( {$0.amount})
                let income = amountArr.reduce(0, +)
                self.incomeDisplayLabel.text = income.clean
                
                // calculate and show total expense
                let filteredExpense = self.transactionDataArr.filter( {$0.transType == TransactionType.expense} )
                let amountArr1 = filteredExpense.map( {$0.amount})
                let expense = amountArr1.reduce(0, +)
                self.expenseDisplayLabel.text = expense.clean
                
                // calculate and show total balance
                let currentBalance = Double(income - expense).clean
                self.balanceDisplayLabel.text = currentBalance
            }
        })
    }
    
    @objc func changeSegment(sender: UISegmentedControl) {
        
        now = Foundation.Date()
        let tabBar = tabBarController as! RaisedTabBarViewController
        tabBar.now = now
        
        switch sender.selectedSegmentIndex {
        case 0:// week
            // set start and end day of current week
            let startWeek = now.startOfWeek
            let endWeek = now.endOfWeek
            
            tabBar.currentStartWeek = startWeek?.convertDateToString()
            tabBar.currentEndWeek = endWeek?.convertDateToString()
            tabBar.selectedSegment = 0
            dateLabel.text = "\(tabBar.currentStartWeek!) - \(tabBar.currentEndWeek!)"
            tabBar.start = Int(startWeek!.timeIntervalSince1970 * 1000)
            tabBar.end = Int(endWeek!.timeIntervalSince1970 * 1000)
        case 1:// month
            // set start and end day of current month
            let startMonth = now.startOfMonth
            let endMonth = now.endOfMonth
            
            tabBar.currentMonth = startMonth?.getMonthName()
            tabBar.selectedSegment = 1
            dateLabel.text = tabBar.currentMonth
            tabBar.start = Int(startMonth!.timeIntervalSince1970 * 1000)
            tabBar.end = Int(endMonth!.timeIntervalSince1970 * 1000)
        default:// year
            // set start and end day of current year
            let startOfYear = now.startOfYear
            let endOfYear = now.endOfYear
            
            tabBar.currentYear = startOfYear?.getYear()
            tabBar.selectedSegment = 2
            dateLabel.text = tabBar.currentYear
            tabBar.start = Int(startOfYear!.timeIntervalSince1970 * 1000)
            tabBar.end = Int(endOfYear!.timeIntervalSince1970 * 1000)
        }
        
        // load current week/month/year transactions depend on selected segment
        loadTransactions(tabBar.start, tabBar.end)
    }
    
    // change date depend on next/back buttons and week/month/year segment
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
        case 0:// week
            start = currentDate.startOfWeek!
            end = currentDate.endOfWeek!
            if(sender == forwardButton) {
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
                dateLabel.text = "\(tab.currentStartWeek!) - \(tab.currentEndWeek!), '\(nextStart.getYearInShortFormat())"
            } else {
                dateLabel.text = "\(tab.currentStartWeek!) - \(tab.currentEndWeek!)"
            }
        case 1:// month
            start = currentDate.startOfMonth!
            end = currentDate.endOfMonth!
            if (sender == forwardButton) {
                nextStart = start.add(months: 1)
                nextEnd = end.add(months: 1)
            } else {
                nextStart = start.subtract(months: 1)
                nextEnd = end.subtract(months: 1)
            }
            
            tab.currentMonth = nextStart.getMonthName()
            
            if (nextStart.getYear() != Foundation.Date().getYear()) {
                dateLabel.text = tab.currentMonth! + " " + (nextStart.getYear())
            } else {
                dateLabel.text = tab.currentMonth
            }
        case 2:// year
            start = currentDate.startOfYear!
            end = currentDate.endOfYear!
            
            if(sender == forwardButton) {
                nextStart = start.add(years: 1)
                nextEnd = end.add(years: 1)
            } else {
                nextStart = start.subtract(years: 1)
                nextEnd = end.subtract(years: 1)
            }
            
            tab.currentYear = nextStart.getYear()
            
            dateLabel.text = tab.currentYear
        default:
            break
        }
        
        let startTime = Int(nextStart.timeIntervalSince1970 * 1000)
        let endTime = Int(nextEnd.timeIntervalSince1970 * 1000)
        tab.start = startTime
        tab.end = endTime
        
        // load changed week/month/year transactions
        loadTransactions(startTime, endTime)
    }
    
    // add expense/income transaction
    func addTransaction(date: String, amount: Double, notes: String, category: String,transDate: Int, transType: String) {
        
        let item = Transaction(date: date, amount:  amount, notes: notes, category: category,transDate: transDate, transType: transType)
        let itemRef = self.ref.childByAutoId()
        itemRef.setValue(item.toAnyObject())
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
    
}

//MARK: - Extensions

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactionDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.transactionViewCell, for: indexPath) as! transactionDataTableViewCell
    
        cell.dateCell.text = transactionDataArr[indexPath.row].date
        cell.categoryCell.text = transactionDataArr[indexPath.row].category
        
        // check income or expense
        cell.amountCell.text = (transactionDataArr[indexPath.row].transType == TransactionType.income ? "+ ": "- ") + transactionDataArr[indexPath.row].amount.clean
        
        if transactionDataArr[indexPath.row].notes.isEmpty == true {
            // show category if note is empty
            cell.notesCell.text = transactionDataArr[indexPath.row].category
        }
        else {
            
            var note = transactionDataArr[indexPath.row].notes
            // check note characters count
            if(note.count >= 20){
                let index = note.index(note.startIndex, offsetBy: 20)
                note = String(note[..<index]).appending("...")
            }
            cell.notesCell.text = note
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        // set current selected index to update transaction
        selectedIndex = indexPath.row
        performSegue(withIdentifier: Identifier.addTransaction, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // swipe to delete from firebase and table view
        if editingStyle == .delete {
            
            transactionDataArr[indexPath.row].ref?.removeValue()
            transactionDataArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifier.addTransaction {
            
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! AddTransactionViewController
            targetController.delegate = self
            if selectedIndex != -1 {
                // to update transaction (-1 is for new transaction and others are update)
                targetController.transaction = transactionDataArr[selectedIndex]
            }
        }
    }
}
