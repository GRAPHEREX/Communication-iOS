//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum WalletInternalError: Error, CustomStringConvertible, LocalizedError {
    case unknown(String)
    case fontNotFoundError(String)
    case fontRegistrationError(String)
    
    var description: String {
        switch self {
        case .fontNotFoundError(let name):
            return "Font \(name) not found in GrapherexWallet bundle!"
        case .fontRegistrationError(let name):
            return "Failed to register font \(name) in GrapherexWallet bundle!"
        case .unknown(let msg):
            return "Unknown error: \(msg)"
        }
    }
    
    var errorDescription: String? {
        return description
    }
}
