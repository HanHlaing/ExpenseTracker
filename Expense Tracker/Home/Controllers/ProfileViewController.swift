//
//  ProfileViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 20/12/2021.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var userRoot :DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = Auth.auth().currentUser{
            self.usernameLabel.text = user.displayName
            self.emailLabel.text = user.email
            userRoot = userRoot.child(user.uid)
        }
    }
    
    @IBAction func signoutTapped(_ sender: Any) {
        
        
        let singoutAlert = UIAlertController(title: "Sign out", message: "Are you sure want sign out?", preferredStyle: UIAlertController.Style.alert)

        singoutAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            try! Auth.auth().signOut()
        }))

        singoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))

        present(singoutAlert, animated: true, completion: nil)
    }
    
}
