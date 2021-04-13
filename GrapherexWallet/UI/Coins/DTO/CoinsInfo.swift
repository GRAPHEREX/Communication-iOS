//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

struct CoinsInfo {
    let totalBalance: String
    let marketCap: String
    let volumeTrade: String
    let btcDominance: String
    let items: [CoinDataItem]
    
    static var noInfo: CoinsInfo {
        return CoinsInfo(totalBalance: "-",
                           marketCap: "-",
                           volumeTrade: "-",
                           btcDominance: "-",
                           items: [])
    }
}
