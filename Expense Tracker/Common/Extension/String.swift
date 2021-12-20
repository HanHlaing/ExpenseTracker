//
//  String.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 19/12/2021.
//

import Foundation

extension String {
    
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    
    func convertToDate() -> Foundation.Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateObject = dateFormatter.date(from: self)
        return dateObject!
    }
    
    func convertCurrencyToDouble() -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        return numberFormatter.number(from: self)?.doubleValue
    }
    
    func getMonth() -> String {
        switch self {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        default:
            return "Dec"
        }
    }
    
    func formatDateString(separation: String) -> [String] {
        let str = self.components(separatedBy: separation)
        return str
    }

    func getDayNameBy() -> String {
        let df  = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        let date = df.date(from: self)!
        df.dateFormat = "EEEE"
        return df.string(from: date);
    }
}
