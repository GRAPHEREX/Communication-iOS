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
    case noWalletConfigurationFound
    case networkConnectionError
    
    var description: String {
        switch self {
        case .jsonSerializationError:
            return "JSON serialization error"
        case .unableToProcessServerResponseError:
            return "Unable to process server response error"
        case .tokenExpiredError:
            return "Access token expired error"
        case .noWalletConfigurationFound:
            return "No valid wallet configuration found"
        case .requestConstructionError:
            return "Request construction error"
        case .networkConnectionError:
            return "Network error. Please check your Internet connection"
        case .unknown:
            return "Unknown error"
        }
    }
    
    var errorDescription: String? {
        return description
    }
}
