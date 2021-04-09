//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

typealias WalletId = String

struct WalletCredentials: Codable {
    let id: WalletId
    let name: String?
    let pin: String?
    let isHidden: Bool
}
