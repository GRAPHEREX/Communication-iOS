//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public struct CryptoAuthError: RawRepresentable, Hashable, Error {
    public typealias RawValue = String

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public let rawValue: RawValue
}

//TODO: - Remove unused errors
extension CryptoAuthError {

    /// Headers do not satisfy the request
    public static let headerDenied: Self = Self(rawValue: "header_denied")

    /// Bearer token is not valid or does not exist
    public static let bearer: Self = Self(rawValue: "bearer_validation")

    /// Device ID is not valid
    public static let deviceId: Self = Self(rawValue: "deviceID_validation")

    /// Device type is not valid
    public static let deviceType: Self = Self(rawValue: "deviceType_validation")

    /// Request ID is not valid
    public static let requestId: Self = Self(rawValue: "requestID_validation")

    /// User validation is not performed, contact the administrator
    public static let userValidation: Self = Self(rawValue: "validation_user")

    /// User status validation is not performed, contact the administrator
    public static let userStatusValidation: Self = Self(rawValue: "validation_user")

    /// Request body violation
    public static let bodyViolation: Self = Self(rawValue: "body_violation")

    /// Body is not valid
    public static let bodyValidation: Self = Self(rawValue: "validation_body")

    /// The resource owner or authorization server denied the request
    public static let accessDenied: Self = Self(rawValue: "access_denied")

    /// Can't change state
    public static let storageRefused: Self = Self(rawValue: "storage_refused")

    /// User is not active
    public static let userNotActive: Self = Self(rawValue: "user_not_active")

    /// User is active, please use reset method
    public static let userActive: Self = Self(rawValue: "user_active")

    /// User is banned
    public static let userBanned: Self = Self(rawValue: "user_banned")

    /// Destination user has blocked you
    public static let destinationUserBlocked: Self = Self(rawValue: "user_blocked")

    /// User is already blocked
    public static let userAlreadyBlocked: Self = Self(rawValue: "user_already_blocked")
    public static let blockedByUs: Self = Self(rawValue: "blocked_by_us")
    public static let blockedByThem: Self = Self(rawValue: "blocked_by_them")

    /// User is held, please use reset method or password confirmation method
    public static let userHeld: Self = Self(rawValue: "user_held")

    /// Destination user has forbidden adding his user_id to contacts
    public static let userInvisible: Self = Self(rawValue: "user_invisible")

    /// Unexpected error
    public static let unexpected: Self = Self(rawValue: "unexpected_error")

    /// Trying to add to cantacts yourself and similar...
    public static let wrongDestination = Self(rawValue: "wrong_destination")
}

// MARK: - Equatable

extension CryptoAuthError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
