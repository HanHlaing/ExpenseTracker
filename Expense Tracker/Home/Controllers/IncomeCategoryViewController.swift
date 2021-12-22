//
//  IncomeCategoryViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit

protocol IncomeCategoryDelegateProtocol {
    func getIncomeCategory(category: String)
}

class IncomeCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var categoryTableView: UITableView!
    
    // MARK: variables
    var incomeCategory: [String] = ["Salary", "Bonus", "Carry Over"]
    
    var delegate: IncomeCategoryDelegateProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "incomeCategoryCell")
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incomeCategory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        cell.textLabel?.text = self.incomeCategory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = self.incomeCategory[indexPath.row]
        self.delegate?.getIncomeCategory(category: selectedCategory)
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
