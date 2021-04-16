//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum CoinPriceChangeDirection {
    case positive
    case negative
    
    var tintColor: UIColor {
        return self == .positive ? .wlt_positiveChangeColor : .wlt_negativeChangeColor
    }
    
    var icon: String {
        return self == .positive ? "▲" : "▼"
    }
}

struct CoinDataItem {
    let currency: Currency
    let balance: String
    let currencyBalance: String
    let stockPrice: String
    let priceChange: String
    let priceChangeType: CoinPriceChangeDirection
    let wallets: [Wallet]
}
