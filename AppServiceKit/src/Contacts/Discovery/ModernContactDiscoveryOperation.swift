//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import PromiseKit

struct CDSRegisteredContact: Hashable {
    let signalUuid: UUID
    let e164PhoneNumber: String
}

/// Fetches contact info from the ContactDiscoveryService
/// Intended to be used by ContactDiscoveryTask. You probably don't want to use this directly.
class ModernContactDiscoveryOperation: ContactDiscovering {
    static let batchSize = 2048

    private let e164sToLookup: Set<String>
    required init(e164sToLookup: Set<String>) {
        self.e164sToLookup = e164sToLookup
        Logger.debug("with e164sToLookup.count: \(e164sToLookup.count)")
    }

    func perform(on queue: DispatchQueue) -> Promise<Set<DiscoveredContactInfo>> {
        firstly { () -> Promise<[Set<SignalRecipient>]> in
            // First, build a bunch of batch Promises
            let batchOperationPromises = Array(e164sToLookup)
                .chunked(by: Self.batchSize)
                .map { makeContactDiscoveryRequest(e164sToLookup: $0) }

            // Then, wait for them all to be fulfilled before joining the subsets together
            return when(fulfilled: batchOperationPromises)

        }.map(on: queue) { (setArray) -> Set<DiscoveredContactInfo> in
            setArray.reduce(into: Set()) { (builder, cdsContactSubset) in
                builder.formUnion(cdsContactSubset.map {
                    DiscoveredContactInfo(e164: $0.recipientPhoneNumber, uuid: $0.recipientUUID.flatMap({ UUID(uuidString: $0) }))
                })
            }
        }.recover(on: queue) { error -> Promise<Set<DiscoveredContactInfo>> in
            throw Self.prepareExternalError(from: error)
        }
    }

    // Below, we have a bunch of then blocks being performed on a global concurrent queue
    // It might be worthwhile to audit and see if we can move these onto the queue passed into `perform(on:)`

    private func makeContactDiscoveryRequest(e164sToLookup: [String]) -> Promise<Set<SignalRecipient>> {
        
        return Promise { resolver in
            ContactsUpdater.shared().lookupIdentifiers(e164sToLookup, success: {
                resolver.fulfill(Set($0))
            }, failure: resolver.reject)
        }
    }

    /// Parse the error and, if appropriate, construct an error appropriate to return upwards
    /// May return the provided error unchanged.
    class func prepareExternalError(from error: Error) -> Error {
        // Network connectivity failures should never be re-wrapped
        if IsNetworkConnectivityFailure(error) {
            return error
        }
        return error
    }
}
