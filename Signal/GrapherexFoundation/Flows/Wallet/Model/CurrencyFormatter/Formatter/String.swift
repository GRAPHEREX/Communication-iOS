//
//  String.swift
//  CurrencyText
//
//  Created by Felipe Lefèvre Marino on 4/3/18.
//  Copyright © 2018 Felipe Lefèvre Marino. All rights reserved.
//

import Foundation

public protocol CurrencyString {
    var representsZero: Bool { get }
    var hasNumbers: Bool { get }
    func numeralFormat() -> String
}

//Currency String Extension
extension String: CurrencyString {

    // MARK: Properties
    
    /// Informs with the string represents the value of zero
    public var representsZero: Bool {
        return numeralFormat().replacingOccurrences(of: "0", with: "").count == 0
    }
    
    /// Returns if the string does have any character that represents numbers
    public var hasNumbers: Bool {
        return numeralFormat().count > 0
    }
    // MARK: Functions
    
    /// Updates a currency string decimal separator position based on
    /// the amount of decimal digits desired
    ///
    /// - Parameter decimalDigits: The amount of decimal digits of the currency formatted string
    public mutating func updateDecimalSeparator(decimalDigits: Int) {
        guard decimalDigits != 0 && count >= decimalDigits else { return }
        let decimalsRange = index(endIndex, offsetBy: -decimalDigits)..<endIndex
        
        let decimalChars = self[decimalsRange]
        replaceSubrange(decimalsRange, with: "." + decimalChars)
    }
    
    /// The numeral format of a string - remove all non numerical ocurrences
    ///
    /// - Returns: itself without the non numerical characters ocurrences
    public func numeralFormat() -> String {
        return replacingOccurrences(of:"[^0-9]", with: "", options: .regularExpression)
    }
    
    public func floatFormat(decimalSeparator: String) -> String {
        return replacingOccurrences(of:"[^0-9\(decimalSeparator)]", with: "", options: .regularExpression)
    }
    
    public func decorate(
        primaryAttributes: [NSAttributedString.Key : Any],
        secondaryAttributes: [NSAttributedString.Key : Any]
    ) -> NSAttributedString {
        
        let result = NSMutableAttributedString(string: self)
        if let index = self.firstIndex(of: ",") ?? self.firstIndex(of: ".") {
            let separatorIndex = index.utf16Offset(in: self)
            let firstRange = NSRange(location: 0, length: separatorIndex)
            result.addAttributes(primaryAttributes, range: firstRange)
            let secondRange = NSRange(location: separatorIndex, length: count - separatorIndex)
            result.addAttributes(secondaryAttributes, range: secondRange)
        }
        return result
    }
}

// MARK: - Static constants

extension String {
    public static let negativeSymbol = "-"
}
