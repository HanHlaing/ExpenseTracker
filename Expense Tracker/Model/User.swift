//
//  User.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import Foundation
import Firebase

class User {
    
    let ref: DatabaseReference?
    var currency: String
    var name: String
    var email: String
    var password: String
    var timestamp: Int
    
    init(currency: String, name: String, email: String, password: String, timestamp: String){
        self.ref = nil
        
        self.currency = currency
        self.name = name
        self.email = email
        self.password = password
        self.timestamp = 0
    }
    
    init?(snapshot: DataSnapshot) {
      guard
        let value = snapshot.value as? [String: AnyObject],
        let currency = value["currency"] as? String,
        let name = value["name"] as? String,
        let email = value["email"] as? String,
        let password = value["password"] as? String,
        let timestamp = value["timestamp"] as? Int else {
        return nil
      }
        self.ref = snapshot.ref
        self.currency = currency
        self.name = name
        self.email = email
        self.password = password
        self.timestamp = timestamp
    }
    
    // turn into dictionary
    func toAnyObject() -> Any {
      return [
        "currency": currency,
        "name": name,
        "email": email,
        "timestamp": [".sv": "timestamp"]
      ]
    }
}
