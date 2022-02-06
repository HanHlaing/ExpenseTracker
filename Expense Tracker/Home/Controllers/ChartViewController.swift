//
//  ChartViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit
import Firebase
import Charts

class ChartViewController: UIViewController  {
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currentSumLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noTransactionLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var constraintCategoryTableHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    
    var _refHandle: DatabaseHandle!
    let ref = Database.database().reference(withPath:FirebaseDatabase.transactions).child(UserManager.shared.userID!)
    var transType: String = "expense" // set expense by default
    var segment: UISegmentedControl!
    var now = Foundation.Date()
    var categroyKeyArray = [String]()
    var categoryValueArray = [Double]()
    var percentArray = [Double]()
    
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
            dateLabel.text = tabBar.currentMonth! + " " + tabBar.currentYear!
        default:
            segment.selectedSegmentIndex = 2
            dateLabel.text = tabBar.currentYear
        }
        // load transactions of current month and reload data to synchronize changes from home
        loadStaticstic(tabBar.start,tabBar.end,transType)
    }
    
    deinit {
        if let refHandle = _refHandle {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    
    //MARK: - Actions
    
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
    
    @IBAction func segmentedControl(_ sender: Any) {
        let tabBar = tabBarController as! RaisedTabBarViewController
        switch segmentedControl.selectedSegmentIndex{
        case 0: loadStaticstic(tabBar.start,tabBar.end,TransactionType.expense)
            transType = TransactionType.expense
        case 1: loadStaticstic(tabBar.start,tabBar.end,TransactionType.income)
            transType = TransactionType.income
        default: break;
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
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    func loadStaticstic(_ start: Int, _ end: Int,_ transType: String){
       
        // synchronize data to table and chart from firebase by using transDate
        _refHandle = ref.queryOrdered(byChild: "transDate").queryStarting(atValue: start).queryEnding(atValue:end).observe(.value, with: {  snapshot in
            
            var transactions = [String: Double]()
            var totalAmount = 0.0
            self.categroyKeyArray.removeAll()
            self.categoryValueArray.removeAll()
            self.percentArray.removeAll()
            
            for child in snapshot.children.allObjects {
                
                if let nestedSnapshot = child as? DataSnapshot,
                   let type = nestedSnapshot.childSnapshot(forPath: "transType").value as? String,
                   let category = nestedSnapshot.childSnapshot(forPath: "category").value as? String,
                   let amount = nestedSnapshot.childSnapshot(forPath: "amount").value as? Double {
                    
                    // add transactions depend on transaction type by grouping category
                    if(transType == type){
                        
                        totalAmount += amount
                        if let value = transactions[category] {
                            transactions[category] = value + amount
                        } else {
                            transactions[category] = amount
                        }
                    }
                }
                
            }
            
            if transactions.isEmpty {
                
                self.noTransactionLabel.text = "No Chart Data Available"
                self.setVisibility(false)
            } else {
                
                self.setVisibility(true)
                // sort desc order by amount
                let sortedDictionary = transactions.sorted { $0.1 > $1.1 } .map { $0 }
                
                for (key, value) in sortedDictionary {
                    self.categroyKeyArray.append(key)
                    self.categoryValueArray.append(value)
                    self.percentArray.append((Double(value) / Double(totalAmount)) * 100.0)
                }
                
                // show total amount and reload table
                self.currentSumLabel.text = (self.categoryValueArray.reduce(0, +)).clean
            }
            
            self.categoryTableView.reloadData()
            // pie chart
            self.customizeChart(dataPoints: self.categroyKeyArray, values: self.percentArray)
            
            self.constraintCategoryTableHeight.constant = CGFloat((43.5 * Double(self.categroyKeyArray.count)))
        })
    }
    
    func setVisibility(_ visibility:Bool) {
        
        noTransactionLabel.isHidden = visibility
        categoryLabel.isHidden = !visibility
        currentSumLabel.isHidden = !visibility
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
            dateLabel.text = tabBar.currentMonth! + " " + tabBar.currentYear!
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
        loadStaticstic(tabBar.start, tabBar.end,transType)
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
            
            if (nextEnd.getYear() != String(Calendar.current.component(.year, from: Date()))) {
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
            
            dateLabel.text = tab.currentMonth! + " " + (nextStart.getYear())
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
        loadStaticstic(startTime, endTime,transType)
        
    }
    
    // show pie chart with percentage
    func customizeChart(dataPoints: [String], values: [Double]) {
        var dataEntries = [ChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .percent
        format.maximumFractionDigits = 1
        format.multiplier = 1.0
        format.percentSymbol = " %"
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFont(.systemFont(ofSize: 11, weight: .bold))
        pieChartData.setValueTextColor(.white)
        pieChartData.setValueFormatter(formatter)
        pieChart.data = pieChartData
        pieChart.setNeedsDisplay()
    }
    
    // show ramdon color in pie chart
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }

}

//MARK: - Extension

extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categroyKeyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.statsCategoryCell, for: indexPath)
        cell.textLabel?.text = categroyKeyArray[indexPath.row]
        cell.detailTextLabel?.text = categoryValueArray[indexPath.row].clean
        return cell
    }
}
