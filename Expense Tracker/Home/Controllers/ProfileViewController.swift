//
//  ProfileViewController.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 20/12/2021.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            self.usernameLabel.text = user.displayName
            self.emailLabel.text = user.email
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if NetworkStatus.isConnectedToNetwork() {
            
            QuoteClient.getQuote(completion: handleQuoteDataResponse(quote:error:))
        } else {
            
            if let localData = self.readLocalFile(forName: "quotes") {
                self.parse(jsonData: localData)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func signoutTapped(_ sender: Any) {
        
        let singoutAlert = UIAlertController(title: "Sign out", message: "Are you sure want sign out?", preferredStyle: UIAlertController.Style.alert)
        
        singoutAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            UserManager.shared.clearUserID()
            try! Auth.auth().signOut()
        }))
        
        singoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(singoutAlert, animated: true, completion: nil)
    }
    
    //MARK: - Private Methods
    
    func handleQuoteDataResponse(quote: Quote?, error:Error?) {
        
        if let quote = quote {
            quoteTextView.text = "\" \(quote.content ?? "")\" \n \n \(quote.author ?? "")"
        } else {
            
            if let localData = self.readLocalFile(forName: "quotes") {
                self.parse(jsonData: localData)
            }
        }
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parse(jsonData: Data) {
        
        do {
            let decodedData = try JSONDecoder().decode([Quote].self,
                                                       from: jsonData)
            
            let randomInt = Int.random(in: 0..<decodedData.count)
            quoteTextView.text = "\" \(decodedData[randomInt].content ?? "")\" \n \n \(decodedData[randomInt].author ?? "")"
        } catch {
            print("decode error \(error)")
        }
    }
    
}
