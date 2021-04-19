//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct CoinWalletsInfo {
    let coinName: String
    let coinIcon: String
    let totalBalance: String
    let totalCurrencyBalance: String
    let marketCap: String
    let volumeTrade: String
    let price: String
    let wallets: [WalletInfo]
}
