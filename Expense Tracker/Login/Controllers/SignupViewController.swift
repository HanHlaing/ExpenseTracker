//
//  SignupViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit

class SignupViewController: UIViewController {

    class func instantiateVC() -> SignupViewController {
        guard let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController else {
            return SignupViewController()
        }
        return vc
    }
    
    // MARK: - Properties
    
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextfield: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var signupButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
    }
    
    //MARK: - Actions
    
    private func configureUI() {
        firstnameTextField.addDepth()
        lastnameTextfield.addDepth()
        emailTextField.addDepth()
        passwordTextfield.addDepth()
        signupButton.makecoloredButton()
        emailTextField.delegate = self
        passwordTextfield.delegate = self
        firstnameTextField.delegate = self
        lastnameTextfield.delegate = self
    }
    
}

//MARK: - Extensions

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
