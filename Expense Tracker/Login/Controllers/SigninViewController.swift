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
        NotificationCenter.default.removeObserver(self)
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
            
            handleSignIn()
        }
        
    }
    
    @IBAction func SignupTapped(_ sender: Any) {
    
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
    
    func handleSignIn() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextfield.text else { return }
        
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
    
    // Set the view origin y after showing keyboard
    @objc func keyboardWillAppear(notification: Notification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        loginButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - loginButton.frame.height / 2)
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
