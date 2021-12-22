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
    var uid: String
    var name: String
    var email: String
    var timestamp: Int
    
    init(uid: String, name: String, email: String){
        self.ref = nil
        
        self.name = name
        self.email = email
        self.uid = uid
        self.timestamp = 0
    }
    
    init?(snapshot: DataSnapshot) {
      guard
        let value = snapshot.value as? [String: AnyObject],
        let name = value["name"] as? String,
        let email = value["email"] as? String,
        let uid = value["uid"] as? String,
        let timestamp = value["timestamp"] as? Int else {
        return nil
      }
        self.ref = snapshot.ref
        self.name = name
        self.email = email
        self.uid = uid
        self.timestamp = timestamp
    }
    
    // turn into dictionary
    func toAnyObject() -> Any {
      return [
        "name": name,
        "email": email,
        "uid": uid,
        "timestamp": [".sv": "timestamp"]
      ]
    }
}
