//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import PromiseKit

@objc(OWSLegacyContactDiscoveryOperation)
public class LegacyContactDiscoveryOperation: OWSOperation {

    @objc
    public var registeredPhoneNumbers: Set<String>?

    @objc
    public var registeredAddresses: Set<SignalServiceAddress>?

    private let phoneNumbersToLookup: [String]

    // MARK: - Initializers

    @objc
    public required init(phoneNumbersToLookup: [String]) {
        self.phoneNumbersToLookup = phoneNumbersToLookup
        Logger.debug("with phoneNumbersToLookup: \(phoneNumbersToLookup.count)")
    }

    // MARK: - OWSOperation Overrides

    // Called every retry, this is where the bulk of the operation's work should go.
    override public func run() {
        Logger.debug("")

        guard !isCancelled else {
            Logger.info("no work to do, since we were canceled")
            self.reportCancelled()
            return
        }

        var phoneNumbersByHashes: [String: String] = [:]

        for phoneNumber in phoneNumbersToLookup {
            guard let hash = Cryptography.truncatedSHA1Base64EncodedWithoutPadding(phoneNumber) else {
                owsFailDebug("could not hash recipient id: \(phoneNumber)")
                continue
            }
            assert(phoneNumbersByHashes[hash] == nil)
            phoneNumbersByHashes[hash] = phoneNumber
        }

        let hashes: [String] = Array(phoneNumbersByHashes.keys)

        let request = OWSRequestFactory.contactsIntersectionRequest(withHashesArray: hashes)

        self.networkManager.makeRequest(
            request,
            success: { (task, responseDict) in
                do {
                    self.registeredPhoneNumbers = try self.parse(response: responseDict, phoneNumbersByHashes: phoneNumbersByHashes)
                    self.reportSuccess()
                } catch {
                    self.reportError(withUndefinedRetry: error)
                }
        },
            failure: { (task, error) in
                guard let response = task.response as? HTTPURLResponse else {
                    let responseError: NSError = OWSErrorMakeUnableToProcessServerResponseError() as NSError
                    responseError.isRetryable = true
                    self.reportError(responseError)
                    return
                }

                guard response.statusCode != 413 else {
                    let nsError = OWSErrorWithCodeDescription(OWSErrorCode.contactsUpdaterRateLimit, "Contacts Intersection Rate Limit") as NSError
                    nsError.isRetryable = false
                    self.reportError(nsError)
                    return
                }
                
                self.reportError(withUndefinedRetry: error)
            }
        )
    }

    // MARK: Private Helpers

    private func parse(response: Any?, phoneNumbersByHashes: [String: String]) throws -> Set<String> {

        guard let responseDict = response as? [String: AnyObject] else {
            let responseError: NSError = OWSErrorMakeUnableToProcessServerResponseError() as NSError
            responseError.isRetryable = true

            throw responseError
        }

        guard let contactDicts = responseDict["contacts"] as? [[String: AnyObject]] else {
            let responseError: NSError = OWSErrorMakeUnableToProcessServerResponseError() as NSError
            responseError.isRetryable = true

            throw responseError
        }

        var registeredRecipientIds: Set<String> = Set()

        for contactDict in contactDicts {
            guard let hash = contactDict["token"] as? String, hash.count > 0 else {
                owsFailDebug("hash was unexpectedly nil")
                continue
            }

            guard let phoneNumber = phoneNumbersByHashes[hash], phoneNumber.count > 0 else {
                owsFailDebug("phoneNumber was unexpectedly nil")
                continue
            }

            guard phoneNumbersToLookup.contains(phoneNumber) else {
                owsFailDebug("unexpected phoneNumber")
                continue
            }

            registeredRecipientIds.insert(phoneNumber)
        }

        return registeredRecipientIds
    }

}

enum ContactDiscoveryError: Error {
    case parseError(description: String)
    case assertionError(description: String)
    case clientError(underlyingError: Error)
    case serverError(underlyingError: Error)
}

extension ContactDiscoveryService.ServiceError: OperationError {
    var isRetryable: Bool {
        switch self {
        case .error5xx:
            return true
        case .tooManyRequests:
            return false
        case .error4xx:
            return false
        case .invalidResponse:
            return true
        }
    }
}
