//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum WalletError: Error, CustomStringConvertible, LocalizedError {
    case unknown
    case jsonSerializationError
    case requestConstructionError
    case unableToProcessServerResponseError
    case tokenExpiredError
    case networkConnectionError
    case noWalletCredentialsFoundError
    
    var description: String {
        switch self {
        case .jsonSerializationError:
            return "JSON serialization error"
        case .unableToProcessServerResponseError:
            return "Unable to process server response error"
        case .tokenExpiredError:
            return "Access token expired error"
        case .requestConstructionError:
            return "Request construction error"
        case .networkConnectionError:
            return "Network error. Please check your Internet connection"
        case .noWalletCredentialsFoundError:
            return "Wallet credentials not found"
        case .unknown:
            return "Unknown error"
        }
    }
    
    var errorDescription: String? {
        return description
    }
}
