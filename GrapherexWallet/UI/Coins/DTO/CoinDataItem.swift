//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct CoinDataItem {
    let coinTitle: String
    let currency: Currency
    let currencyIcon: String
    let balance: String
    let currencyBalance: String
    let stockPrice: String
    let wallets: [Wallet]
}
