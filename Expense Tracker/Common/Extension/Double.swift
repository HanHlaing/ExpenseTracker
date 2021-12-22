//
//  Double.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 22/12/2021.
//

import Foundation

extension Double {
    var clean: String {
       return String(format: "%.2f", self)
    }
}
