//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension String {
    func removingTrailingSlash() -> String {
        if last == "/" {
            return String(self.dropLast())
        }
        return self
    }
    
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.walletBundle, comment: "")
    }
    
    // MARK: - Currency related methods
    func appendingLeadingCurrencySymbol(forCode code: String, divider: String = " ") -> String {
        return String.getSymbolForCurrencyCode(code: code) + divider + self
    }
    
    static func getSymbolForCurrencyCode(code: String) -> String
    {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? code
    }
}
