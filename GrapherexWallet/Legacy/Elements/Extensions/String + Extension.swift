//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    var integerValue: Int {
        return (self as NSString).integerValue
    }
     
    var dropFirst: String {
        return String(self.dropFirst())
    }
    
    var dropLast: String {
        return String(self.dropLast())
    }

    var isNumeric: Bool {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = numberFormatter.number(from: self)
        return number != nil
    }
    
    var isNotZero: Bool {
        for index in 1...9 {
            if self.contains(String(index)) == true { return true }
        }
        return false
    }
    
    var withoutSpaces: String {
        var string = self
        string.removeAll {
            $0 == " " || $0 == " " // it is different spaces
        }
        return string
    }
    
    var withReplacedSeparators: String {
        return self.replacingOccurrences(of: ",", with: ".")
    }
    
    func hasOnlyOneSymbolOrLess(symbol: String) -> Bool {
        let string = self
        return string.replacingOccurrences(of: "[^\(symbol)]", with: "", options: .regularExpression).count <= 1
    }
}
