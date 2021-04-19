//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension Array where Element == Wallet {
    func totalCoinBalance() -> Double {
        return self.reduce(0, { $0 + $1.balance })
    }
}
