//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum WalletError: Error, CustomStringConvertible, LocalizedError {
    case unknown
    
    var description: String {
        switch self {
        case .unknown:
            return "Unknown error"
        }
    }
    
    var errorDescription: String? {
        return description
    }
}
