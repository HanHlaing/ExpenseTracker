//
//  SignupViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 18/12/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let rootRef = Database.database().reference()
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
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        
        //close the keyboard
        passwordTextfield.resignFirstResponder()
        validateInputs()
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    //MARK: - Private Methods
    
    func actualInput(for textField: UITextField) -> String {
        let text = textField.text ?? ""
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func configureUI() {
        nameTextField.addDepth()
        emailTextField.addDepth()
        passwordTextfield.addDepth()
        signupButton.makecoloredButton()
        emailTextField.delegate = self
        passwordTextfield.delegate = self
        nameTextField.delegate = self
    }
    
    func setLoggingIn(_ signingIn:Bool) {
        
        signingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        nameTextField.isEnabled = !signingIn
        emailTextField.isEnabled = !signingIn
        passwordTextfield.isEnabled = !signingIn
        loginButton.isEnabled = !signingIn
        signupButton.isEnabled = !signingIn
    }
    
    func validateInputs() {
        
        let name = nameTextField.text
        let email = actualInput(for: emailTextField)
        let password = actualInput(for: passwordTextfield)
        switch (name?.isEmpty, email.isEmpty, password.isEmpty) {
        case (true, true, true):
            showErrorAlert( "Required Fileds!", "All fields are required")
        case (true, _, _):
            showErrorAlert( "Required Filed!", "Please enter name")
        case (_,true,_):
            showErrorAlert( "Required Filed!", "Please enter email")
        case (_,_,true):
            showErrorAlert( "Required Filed!", "Please enter password")
        default:
            
            if(!isValidEmail(email)) {
                showErrorAlert( "Required Filed!", "Please enter valid email")
            } else if(password.count < 6){
                showErrorAlert( "Required Filed!", "Enter password at least 6 characters")
            } else {
                
                if NetworkStatus.isConnectedToNetwork() {
                    createNewUser()
                } else {
                    showErrorAlert( "No internet!", "Please check your internet connection.")
                }
            }
        }
    }
    
    func createNewUser() {
        
        setLoggingIn(true)
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextfield.text!, completion: {
            (user,error) in
            if let userfound = user {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameTextField.text!
                changeRequest?.commitChanges { error in
                    
                    self.setLoggingIn(false)
                    if error != nil {
                        
                        self.showErrorAlert( "Error!", error?.localizedDescription ?? "Please correct errors and try again")
                    } else {
                        
                        let userRoot = self.rootRef.child("users/" + userfound.user.uid)
                        let user = User(uid: userfound.user.uid, name: self.nameTextField.text!, email: self.emailTextField.text!)
                        userRoot.setValue(user.toAnyObject())
                    }
                }
            }
            else
            {
                self.setLoggingIn(false)
                self.showErrorAlert( "Error!", error?.localizedDescription ?? "Please correct errors and try again")
            }
        })
    }
}

//MARK: - Extensions

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case nameTextField:
            nameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        case emailTextField:
            emailTextField.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
            break
        case passwordTextfield:
            validateInputs()
            break
        default:
            break
        }
        return true
    }
}
