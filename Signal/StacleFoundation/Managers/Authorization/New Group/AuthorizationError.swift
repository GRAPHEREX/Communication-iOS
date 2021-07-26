import Foundation

public enum AuthorizationError: Error {

    case unknown
    case wrongCredentials
    case sameUserIdAlreadyRegistered
    case noUserId
    case wrongVerificationCode
    case noVerificationCode
    case invalidNewPassword
}
