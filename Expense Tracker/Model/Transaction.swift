//
//  Transaction.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import Foundation
import Firebase

class Transaction {
    
    let ref: DatabaseReference?
    var timestamp: Int
    var date: String
    var amount: String
    var notes: String
    var category: String
    var transDate: Int
    var transType: String
    
    init(date: String, amount: String, notes: String, category: String,transDate: Int,transType: String){
        self.ref = nil
        self.date = date
        self.amount = amount
        self.timestamp = 0
        self.notes = notes
        self.category = category
        self.transDate = transDate
        self.transType = transType
    }
    
    init?(snapshot: DataSnapshot) {
      guard
        let value = snapshot.value as? [String: AnyObject],
        let date = value["date"] as? String,
        let amount = value["amount"] as? String,
        let notes = value["notes"] as? String,
        let category = value["category"] as? String,
        let transDate = value["transDate"] as? Int,
        let transType = value["transType"] as? String,
        let timestamp = value["timestamp"] as? Int else {
        return nil
      }
        self.ref = snapshot.ref
        self.date = date
        self.amount = amount
        self.notes = notes
        self.category = category
        self.transDate = transDate
        self.transType = transType
        self.timestamp = timestamp
    }
    
    // turn into dictionary
    func toAnyObject() -> Any {
      return [
        "date": date,
        "amount": amount,
        "notes": notes,
        "category": category,
        "transDate": transDate,
        "transType": transType,
        "timestamp": [".sv": "timestamp"]
      ]
    }
}

