//
//  ExpenseCategoryViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit

protocol ExpenseCategoryDelegateProtocol {
    func getCategory(category: String)
}

class ExpenseCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var categoryTableView: UITableView!
    
    // MARK: variables
    var expenseCategory: [String] = ["Groceries", "Shopping", "Transportation", "Entertainment", "Eating Out", "Rent"]
    
    var delegate: ExpenseCategoryDelegateProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "categoryCell")
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        categoryTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.expenseCategory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = self.expenseCategory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = self.expenseCategory[indexPath.row]
        self.delegate?.getCategory(category: selectedCategory)
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
}
