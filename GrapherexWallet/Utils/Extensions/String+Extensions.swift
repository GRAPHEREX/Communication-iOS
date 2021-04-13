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
        return NSLocalizedString(self, bundle: Bundle(for: GrapherexWallet.self), comment: "")
    }
    
    static func getSymbolForCurrencyCode(code: String) -> String
    {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code) ?? code
    }
}
