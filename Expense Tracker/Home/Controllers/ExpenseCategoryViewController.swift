//
//  ExpenseCategoryViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit

// send data to add transaction
protocol ExpenseCategoryDelegateProtocol {
    func getCategory(category: String)
}

class ExpenseCategoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    // MARK: variables
    
    // static expense categories
    var expenseCategory: [String] = ["Food","Drinks", "Shopping", "Bills", "Transportation", "Home", "Car","Entertainment", "Clothing", "Insurance", "Tax", "Telephone", "Cigarette", "Beer", "Health", "Sport", "Baby", "Pet", "Beauty", "Electronics", "Hamburger", "Wine", "Vegetables", "Snacks", "Gift", "Social", "Travel","Education", "Fruits", "Book", "Office", "Rent", "Others"]
    
    var delegate: ExpenseCategoryDelegateProtocol? = nil
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: Identifier.expenseCategoryCell)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.reloadData()
    }
    
}

//MARK: - Extensions

extension ExpenseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.expenseCategoryCell, for: indexPath)
        cell.textLabel?.text = expenseCategory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = expenseCategory[indexPath.row]
        delegate?.getCategory(category: selectedCategory)
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
