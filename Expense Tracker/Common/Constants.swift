//
//  Constants.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 26/12/2021.
//

import Foundation

struct FirebaseDatabase {
    static let transactions = "transactions"
    static let users = "users"
}

struct TransactionType {
    static let expense = "expense"
    static let income = "income"
}

struct Identifier {
    static let transactionViewCell = "transactionDataTableViewCell"
    static let addTransaction = "addInput"
    static let addExpenseCategory = "addExpenseCategory"
    static let addIncomeCategory = "addIncomeCategory"
    static let expenseCategoryCell = "categoryCell"
    static let incomeCategoryCell = "incomeCategoryCell"
    static let statsCategoryCell = "statsCategory"
}
