//
//  ChartViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit
import Firebase
import Charts

class ChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    // MARK: variables
    var statsCategory = [String: Int]() // get category from firebase
    //let ref = Database.database().reference(withPath:"transaction-data")
    let ref = Database.database().reference(withPath:"transactions").child("DZIGIY2mpYdVVRyGcBmZGEnzRHm1")
    var tempCategory = ""
    var transType: String = "expense"
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currentMonth: UILabel!
    @IBOutlet weak var currentSum: UILabel!
    @IBOutlet weak var expenseCategory: UITableView!
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    var segment: UISegmentedControl!
    var empty = [String]()
    var now = Foundation.Date()

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
        
        
        
        // display month
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        currentMonth.text = formatter.string(from: date)
       
       
        
        // display table
        expenseCategory.delegate = self
        expenseCategory.dataSource = self
        
        let start = Int(tabBar.now.startOfMonth!.timeIntervalSince1970 * 1000)
        let end = Int(tabBar.now.endOfMonth!.timeIntervalSince1970 * 1000)
        loadStaticstic(start,end,transType)
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
    
    func loadStaticstic(_ start: Int, _ end: Int,_ transType: String){
        
        // display sum
        currentSum.text = "$" + String(UserDefaults.standard.integer(forKey: transType == "expense" ? "expenseBalance":"incomeBalance"))
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        var sum = monthlyData[YearMonth(year:year, month:month)]
        
        ref.queryOrdered(byChild: "transDate").queryStarting(atValue: start).queryEnding(atValue:end).observe(.value, with: {  snapshot in
            var newItems = [String: Int]()
            var actualData = [String]()
            var intData = [Int]()
            var keyArray = [String]()
            var valueArray = [Int]()
            var percentArray = [Double]()
            var totalAmount = 0
            
            for child in snapshot.children.allObjects {
                
                if let nestedSnapshot = child as? DataSnapshot,
                   let type = nestedSnapshot.childSnapshot(forPath: "transType").value as? String,
                   let item = nestedSnapshot.childSnapshot(forPath: "category").value as? String,
                   let amount = nestedSnapshot.childSnapshot(forPath: "amount").value as? String {
                    
                    
                    if(transType == type){
                        
                        if(self.tempCategory != item) {
                            actualData.removeAll() // initialze array
                        }
                        
                        actualData.append(amount)
                        totalAmount += Int(amount)!
                        intData = actualData.compactMap{ Int($0) }
                        sum = intData.reduce(0, +)
                        newItems[item] = sum // add to dictonary
                        self.tempCategory = item
                    }
                 }
    
            }
          
            
            self.statsCategory = newItems
           
            for (key, value) in self.statsCategory {
                keyArray.append(key)
                valueArray.append(value)
                percentArray.append((Double(value) / Double(totalAmount)) * 100.0)
            }
            self.currentSum.text = "$" + String(valueArray.reduce(0, +))
            self.expenseCategory.reloadData()
            // pie chart
            self.customizeChart(dataPoints: keyArray, values: percentArray)

        })
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
    
    @IBAction func segmentedControl(_ sender: Any) {
        let tabBar = tabBarController as! RaisedTabBarViewController
        let start = Int(tabBar.now.startOfMonth!.timeIntervalSince1970 * 1000)
        let end = Int(tabBar.now.endOfMonth!.timeIntervalSince1970 * 1000)
        
        switch segmentedControl.selectedSegmentIndex{
        case 0: loadStaticstic(start,end,"expense")
            transType = "expense"
        case 1: loadStaticstic(start,end,"income")
            transType = "income"
        default: break;
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
            loadStaticstic(Int(startWeek!.timeIntervalSince1970 * 1000), Int(endWeek!.timeIntervalSince1970 * 1000),transType)
        case 1:
            let startMonth = now.startOfMonth
            let endMonth = now.endOfMonth
            
            tabBar.currentMonth = startMonth?.getMonthName()
            tabBar.selectedSegment = 1
            dateLbl.text = tabBar.currentMonth
            loadStaticstic(Int(startMonth!.timeIntervalSince1970 * 1000), Int(endMonth!.timeIntervalSince1970 * 1000),transType)
        default:
            let startOfYear = now.startOfYear
            let endOfYear = now.endOfYear
            tabBar.currentYear = startOfYear?.getYear()
            tabBar.selectedSegment = 2
            dateLbl.text = tabBar.currentYear
            loadStaticstic(Int(startOfYear!.timeIntervalSince1970 * 1000), Int(endOfYear!.timeIntervalSince1970 * 1000),transType)
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
        
        loadStaticstic(startTime, endTime,transType)
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statsCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var keyArray = [String]()
        var valueArray = [Int]()
        for (key, value) in self.statsCategory {
            keyArray.append(key)
            valueArray.append(value)
        }
        valueArray = valueArray.sorted { $0 > $1 }
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCategory", for: indexPath)
        cell.textLabel?.text = keyArray[indexPath.row]
        cell.detailTextLabel?.text = "$" +  String(valueArray[indexPath.row])
        return cell
    }
    
    // pie chart
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