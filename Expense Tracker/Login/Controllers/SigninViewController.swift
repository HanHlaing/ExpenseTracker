//
//  SigninViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import FirebaseAuth

class SigninViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        
    }
    
    //MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        //close the keyboard
        passwordTextfield.resignFirstResponder()
        
        let email = actualInput(for: emailTextField)
        let password = actualInput(for: passwordTextfield)
        switch (email.isEmpty, password.isEmpty) {
        case (true, true):
            showErrorAlert( "Required Fileds!", "Please enter email & password")
        case (true, _):
            showErrorAlert( "Required Filed!", "Please enter email")
        case (_, true):
            showErrorAlert( "Required Filed!", "Please enter password")
        default:
            
            if NetworkStatus.isConnectedToNetwork() {
                
                setLoggingIn(true)
                Auth.auth().signIn(withEmail: email, password: password, completion: {
                   (user,error) in
                    
                    self.setLoggingIn(false)
                    if error != nil, let myerr = error?.localizedDescription {
                        
                        self.showErrorAlert( "Warning!", myerr)
                    }
                })
            } else {
                showErrorAlert( "No internet!", "Please check your internet connection.")
            }
        }
        
    }
    
    @IBAction func SignupTapped(_ sender: Any) {
    
        //vc.viewModel = viewModel
        let identifier = "SignupViewController"
        let vc = storyboard?.instantiateViewController(identifier: identifier) as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    //MARK: - Private methods
    private func configureUI() {
        emailTextField.delegate = self
        passwordTextfield.delegate = self
        emailTextField.addDepth()
        passwordTextfield.addDepth()
        loginButton.makecoloredButton()
    }
    
    func actualInput(for textField: UITextField) -> String {
        let text = textField.text ?? ""
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func setLoggingIn(_ loggingIn:Bool) {
        
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        emailTextField.isEnabled = !loggingIn
        passwordTextfield.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signupButton.isEnabled = !loggingIn
    }

}

//MARK: - Extensions

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
