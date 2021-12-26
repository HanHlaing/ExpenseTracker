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
        dismissKeyboard()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTextField.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
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
            if(!isValidEmail(email)) {
                showErrorAlert( "Required Filed!", "Please enter valid email")
            } else {
                handleSignIn()
            }
        }
        
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        
        let identifier = "SignupViewController"
        let vc = storyboard?.instantiateViewController(identifier: identifier) as! SignupViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        
        if NetworkStatus.isConnectedToNetwork() {
            
            let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
            forgotPasswordAlert.addTextField { (textField) in
                
                textField.placeholder = "Enter email address"
            }
            forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
                
                let resetEmail = forgotPasswordAlert.textFields?.first?.text
                Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                    
                    DispatchQueue.main.async {
                        //Use "if let" to access the error, if it is non-nil
                        if let error = error {
                            let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)
                        } else {
                            let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                            resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetEmailSentAlert, animated: true, completion: nil)
                        }
                    }
                })
            }))
            
            self.present(forgotPasswordAlert, animated: true, completion: nil)
            
        } else {
            showErrorAlert( "No internet!", "Please check your internet connection.")
        }
        
    }
    
    //MARK: - Private Methods
    
    private func configureUI() {
        emailTextField.delegate = self
        passwordTextfield.delegate = self
        emailTextField.addDepth()
        passwordTextfield.addDepth()
        loginButton.makecoloredButton()
    }
    
    func handleSignIn() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextfield.text else { return }
        
        if NetworkStatus.isConnectedToNetwork() {
            
            setLoggingIn(true)
            Auth.auth().signIn(withEmail: email, password: password, completion: {
                (user,error) in
                
                self.setLoggingIn(false)
                if error != nil, let myerr = error?.localizedDescription {
                    
                    self.showErrorAlert( "Error!", myerr)
                }
            })
        } else {
            showErrorAlert( "No internet!", "Please check your internet connection.")
        }
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
        
        switch textField {
        case emailTextField:
            emailTextField.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
            break
        case passwordTextfield:
            handleSignIn()
            break
        default:
            break
        }
        return true
    }
}
