//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum WalletAuthError: Error, CustomStringConvertible, LocalizedError {
    case unknown
    case noAuthTokenFound
    case authTokenSavingError
    case authTokenRemovingError
    
    var description: String {
        switch self {
        case .noAuthTokenFound:
            return "No auth token found error"
        case .authTokenSavingError:
            return "Unable to save auth token"
        case .authTokenRemovingError:
            return "Unable to remove auth token"
        case .unknown:
            return "Unknown error"
        }
    }
    
    var errorDescription: String? {
        return description
    }
}
