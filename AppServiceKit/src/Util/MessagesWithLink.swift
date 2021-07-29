//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalCoreKit

@objc
public class MessagesWithLink: NSObject {

    private static let store = SDSKeyValueStore(collection: "messagesWithLink")

    private class func readReceiptKey(senderAddress: SignalServiceAddress,
                                      messageIdTimestamp: UInt64) -> String {
        return "\(senderAddress.stringForDisplay).\(messageIdTimestamp)"
    }
    
    let thread: TSThread
    public init(thread: TSThread) {
        self.thread = thread
    }
}

// MARK: -

public protocol MessagesWithLinkFinder {
    associatedtype ReadTransaction

    typealias EnumerateTSMessageBlock = (TSMessage, UnsafeMutablePointer<ObjCBool>) -> Void
    func enumerateAllMessagesWithLink(transaction: ReadTransaction, block: @escaping EnumerateTSMessageBlock)
}

// MARK: -

extension MessagesWithLinkFinder {

    public func allMessagesWithViewOnceMessage(transaction: ReadTransaction) -> [TSMessage] {
        var result: [TSMessage] = []
        self.enumerateAllMessagesWithLink(transaction: transaction) { message, _ in
            result.append(message)
        }
        return result
    }
}

// MARK: -

public class AnyMessagesWithLinkFinder {
    lazy var grdbAdapter = GRDBMessagesWithLinkFinder(thread: thread)
    
    let thread: TSThread
    public init(thread: TSThread) {
        self.thread = thread
    }
}

// MARK: -

extension AnyMessagesWithLinkFinder: MessagesWithLinkFinder {
    public func enumerateAllMessagesWithLink(transaction: SDSAnyReadTransaction, block: @escaping EnumerateTSMessageBlock) {
        switch transaction.readTransaction {
        case .grdbRead(let grdbRead):
            grdbAdapter.enumerateAllMessagesWithLink(transaction: grdbRead, block: block)
        default:
            break
        }
    }
}

// MARK: -

class GRDBMessagesWithLinkFinder: MessagesWithLinkFinder {
    
    let thread: TSThread
    init(thread: TSThread) {
        self.thread = thread
    }

    func enumerateAllMessagesWithLink(transaction: GRDBReadTransaction, block: @escaping EnumerateTSMessageBlock) {

//        let sql = """
//        SELECT * FROM \(InteractionRecord.databaseTableName)
//        WHERE \(interactionColumn: .threadUniqueId) = ?
//            AND \(interactionColumn: .isMessageWithLink) == TRUE
//        ORDER BY \(interactionColumn: .receivedAtTimestamp) DESC
//        """
//
//        let cursor = TSInteraction.grdbFetchCursor(sql: sql,
//                                                   arguments: [thread.uniqueId],
//                                                   transaction: transaction)
//        var stop: ObjCBool = false
//        // GRDB TODO make cursor.next fail hard to remove this `try!`
//        while let next = try! cursor.next() {
//            guard let message = next as? TSMessage else {
//                owsFailDebug("expecting message but found: \(next)")
//                return
//            }
//            block(message, &stop)
//            if stop.boolValue {
//                return
//            }
//        }
    }
}

public extension String {
    var isContainURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let result = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        return result != nil
    }
}
