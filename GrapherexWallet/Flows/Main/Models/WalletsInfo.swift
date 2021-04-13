//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct WalletsInfo {
    let totalBalance: String
    let marketCap: String
    let volumeTrade: String
    let btcDominance: String
    let items: [WalletCurrencyItem]
    
    static var noInfo: WalletsInfo {
        return WalletsInfo(totalBalance: "-",
                           marketCap: "-",
                           volumeTrade: "-",
                           btcDominance: "-",
                           items: [])
    }
}
