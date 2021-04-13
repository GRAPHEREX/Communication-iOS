//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import XCGLogger

public let logger = XCGLogger.default

/**
 * We synchronize access to state in this class using this queue.
 */
public func assertOnQueue(_ queue: DispatchQueue) {
    if #available(iOS 10.0, *) {
        dispatchPrecondition(condition: .onQueue(queue))
    } else {
        // Skipping check on <iOS10, since syntax is different and it's just a development convenience.
    }
}

@inlinable
public func AssertIsOnMainThread(file: String = #file,
                                 function: String = #function,
                                 line: Int = #line) {
    if !Thread.isMainThread {
        wltFailDebug("Must be on main thread.", file: file, function: function, line: line)
    }
}

@inlinable
public func wltFailDebug(_ logMessage: String,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {
    logger.error(logMessage)
    let formattedMessage = wltFormatLogMessage(logMessage, file: file, function: function, line: line)
    assertionFailure(formattedMessage)
}

@inlinable
public func wltFail(_ logMessage: String,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) -> Never {
    WLTSwiftUtils.logStackTrace()
    wltFailDebug(logMessage, file: file, function: function, line: line)
    let formattedMessage = wltFormatLogMessage(logMessage, file: file, function: function, line: line)
    fatalError(formattedMessage)
}

@inlinable
public func wltAssertDebug(_ condition: Bool,
                           _ message: @autoclosure () -> String = String(),
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line) {
    if !condition {
        let message: String = message()
        wltFailDebug(message.isEmpty ? "Assertion failed." : message,
                     file: file, function: function, line: line)
    }
}

@inlinable
public func wltAssert(_ condition: Bool,
                      _ message: @autoclosure () -> String = String(),
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    if !condition {
        let message: String = message()
        wltFail(message.isEmpty ? "Assertion failed." : message,
                file: file, function: function, line: line)
    }
}

@inlinable
public func notImplemented(file: String = #file,
                           function: String = #function,
                           line: Int = #line) -> Never {
    wltFail("Method not implemented.", file: file, function: function, line: line)
}

@inlinable
public func wltFormatLogMessage(_ logString: String,
                                file: String = #file,
                                function: String = #function,
                                line: Int = #line) -> String {
    let filename = (file as NSString).lastPathComponent
    // We format the filename & line number in a format compatible
    // with XCode's "Open Quickly..." feature.
    return "[\(filename):\(line) \(function)]: \(logString)"
}

@objc
public class WLTSwiftUtils: NSObject {
    // This method can be invoked from Obj-C to exit the app.
    @objc
    public class func wltFail(_ logMessage: String,
                              file: String = #file,
                              function: String = #function,
                              line: Int = #line) -> Never {
        
        logStackTrace()
        wltFailDebug(logMessage, file: file, function: function, line: line)
        let formattedMessage = wltFormatLogMessage(logMessage, file: file, function: function, line: line)
        fatalError(formattedMessage)
    }
    
    @objc
    public class func logStackTrace() {
        Thread.callStackSymbols.forEach { logger.error($0) }
    }
}

