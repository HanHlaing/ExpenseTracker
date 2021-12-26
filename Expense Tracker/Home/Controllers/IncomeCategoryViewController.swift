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

class IncomeCategoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    // MARK: - Variables
    
    // static income categories
    var incomeCategory: [String] = ["Salary", "Bonus", "Awards", "Sale","Rental", "Refunds", "Coupons", "Lottery", "Investments", "Adjustment", "Others"]
    var delegate: IncomeCategoryDelegateProtocol? = nil
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: Identifier.incomeCategoryCell)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.reloadData()
    }
}

//MARK: - Extensions

extension IncomeCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.incomeCategoryCell, for: indexPath)
        cell.textLabel?.text = incomeCategory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = incomeCategory[indexPath.row]
        delegate?.getIncomeCategory(category: selectedCategory)
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
