//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

enum FeeType: String {
    case personal, `default`
    
    var infoMessage: String {
        switch self {
        case .personal:
            return "Warning! Personal commission mode is only for experienced users!"
        case .default:
            return "The miner fee applies to all transaction sent on the network, and is not paid to Grapherex"
        }
    }
}

struct Fee {
    let formatted: String
}
