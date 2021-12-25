//
//  AddTransactionViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import UIKit


protocol MyDataSendingDelegateProtocol {
    func addTransaction(date: String, amount: String, notes: String, category: String,transDate:Int, transType: String)
    
    func updateTransaction(transaction: Transaction)
}

class AddTransactionViewController: UIViewController, IncomeCategoryDelegateProtocol, ExpenseCategoryDelegateProtocol {
    
    class func instantiateVC() -> AddTransactionViewController {
        guard let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as? AddTransactionViewController else {
            return AddTransactionViewController()
        }
        return vc
    }
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var inputCategory: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Variables
    
    var transaction: Transaction? = nil
    var delegate: MyDataSendingDelegateProtocol? = nil
    var inputStatus: String = "expense" // set to expense by default
    var categoryInput: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        datePicker.timeZone = TimeZone.init(identifier: "UTC")
        configureUI()
        if (transaction != nil) {
            
            self.title = "Edit transaction"
            datePicker.setDate(Date(timeIntervalSince1970: TimeInterval(transaction!.transDate/1000)), animated: false)
            amountTextField.text = transaction?.amount
            noteTextField.text = transaction?.notes
            categoryInput = transaction?.category ?? ""
            inputCategory.setTitle(transaction?.category ?? "Select category", for: .normal)
            segmentedControl.selectedSegmentIndex = (transaction?.transType == "income") ? 1 : 0
            inputStatus = transaction?.transType ?? "expense"
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    // done button
    @IBAction func finishInput(_ sender: Any) {
        // alert if textfield is empty
        if self.amountTextField.text?.isEmpty == true {
            let alertController = UIAlertController(title: "Error", message: "Please enter an amount", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated:true, completion:nil)}
        // alert if category is not selected
        else if categoryInput.isEmpty == true {
            let alertController = UIAlertController(title: "Error", message: "Please select a category", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated:true, completion:nil)}
        // expense
        else if self.delegate != nil && inputStatus == "expense"
        {
            // date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let date = dateFormatter.string(from: self.datePicker.date)
            // amount
            let amount = self.amountTextField.text
            // notes
            let notes = self.noteTextField.text!
            
            let transDate = Int(self.datePicker.date.timeIntervalSince1970 * 1000)
            // delegate
            if transaction != nil {
                transaction?.date = date
                transaction?.amount = amount!
                transaction?.notes = notes
                transaction?.category = categoryInput
                transaction?.transType = "expense"
                self.delegate?.updateTransaction(transaction: self.transaction!)
            } else {
                self.delegate?.addTransaction(date: date, amount: amount!, notes: notes, category: categoryInput,transDate: transDate, transType: "expense")
            }
           
            dismiss(animated: true, completion: nil)
        }
        // income
        else if self.delegate != nil && inputStatus == "income" {
            // date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let date = dateFormatter.string(from: self.datePicker.date)
            // amount
            let amount = self.amountTextField.text
            // notes
            let notes = self.noteTextField.text!
            
            let transDate = Int(self.datePicker.date.timeIntervalSince1970 * 1000)
            // delegate
            if transaction != nil {
                transaction?.date = date
                transaction?.amount = amount!
                transaction?.notes = notes
                transaction?.category = categoryInput
                transaction?.transType = "income"
                self.delegate?.updateTransaction(transaction: self.transaction!)
            } else {
                self.delegate?.addTransaction(date: date, amount: amount!, notes: notes, category: categoryInput,transDate: transDate, transType: "income")
            }

            dismiss(animated: true, completion: nil)
        }
    }
    
    // cancel button
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // income expense segmented control
    @IBAction func segmentedControl(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            clearCategory()
            inputStatus = "expense";
        case 1:
            clearCategory()
            inputStatus = "income";
        default: break;
        }
    }
    
    // category button
    @IBAction func categoryButton(_ sender: Any) {
        if inputStatus == "expense" {
            self.performSegue(withIdentifier: "addExpenseCategory", sender: Any?.self)
        }
        else {
            self.performSegue(withIdentifier: "addIncomeCategory", sender: Any?.self)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureUI() {

        amountTextField.delegate = self
        noteTextField.delegate = self
        submitButton.makecoloredButton()
    }
    
    func clearCategory() {
        categoryInput = ""
        inputCategory.setTitle("Select category", for: .normal)
    }
    
    func getCategory(category: String) {
        categoryInput = category
        inputCategory.setTitle(category, for: .normal)
    }
    
    func getIncomeCategory(category: String) {
        categoryInput = category
        inputCategory.setTitle(category, for: .normal)
    }
    
    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpenseCategory" {
            let secondVC = segue.destination as! ExpenseCategoryViewController
            secondVC.delegate = self
        }
        else if segue.identifier == "addIncomeCategory" {
            let secondVC = segue.destination as! IncomeCategoryViewController
            secondVC.delegate = self
        }
    }
}

extension AddTransactionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == noteTextField {
            
            let maxLength = 36
                let currentString: NSString = (textField.text ?? "") as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
        } else {
         
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2 && newText.count <= (newText.contains(".") ? 12 : 9)
        }
    }
}
