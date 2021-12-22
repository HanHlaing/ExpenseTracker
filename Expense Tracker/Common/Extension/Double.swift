//
//  Double.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 22/12/2021.
//

import Foundation

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
