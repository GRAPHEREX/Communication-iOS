//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct CoinsInfo {
    let totalBalance: String
    let marketCap: String
    let volumeTrade: String
    let btcDominance: String
    let spendValue: String
    let incomeValue: String
    let spendIncomeProportion: Float
    let items: [CoinInfo]
    
    static var noInfo: CoinsInfo {
        return CoinsInfo(totalBalance: "-",
                           marketCap: "-",
                           volumeTrade: "-",
                           btcDominance: "-",
                           spendValue: "-",
                           incomeValue: "-",
                           spendIncomeProportion: 0,
                           items: [])
    }
}
