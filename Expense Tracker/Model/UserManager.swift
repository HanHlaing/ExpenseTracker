//
//  UserManager.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 21/12/2021.
//

import Foundation

class UserManager {
    
    static let shared = UserManager()
    
    enum UserKeys: String {
        case userIDKey
    }
    
    var userID: String? {
        get {
            UserDefaults.standard.string(forKey: UserKeys.userIDKey.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserKeys.userIDKey.rawValue)
        }
    }
    
    func clearUserID() {
        UserDefaults.standard.removeObject(forKey: UserKeys.userIDKey.rawValue)
    }
}
