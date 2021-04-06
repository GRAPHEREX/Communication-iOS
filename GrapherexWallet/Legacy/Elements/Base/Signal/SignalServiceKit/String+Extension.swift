//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

enum StringError: Error {
    case invalidCharacterShift
}

// MARK: - Selector Encoding

private let selectorOffset: UInt32 = 17

@objc
public extension NSString {
    func ows_truncated(toByteCount byteCount: UInt) -> NSString? {
        return (self as String).truncated(toByteCount: byteCount) as NSString?
    }
}

public extension String {
    func caesar(shift: UInt32) throws -> String {
        let shiftedScalars: [UnicodeScalar] = try unicodeScalars.map { c in
            guard let shiftedScalar = UnicodeScalar((c.value + shift) % 127) else {
                throw StringError.invalidCharacterShift
            }
            return shiftedScalar
        }
        return String(String.UnicodeScalarView(shiftedScalars))
    }
    
    var stripped: String {
        // MARK: - SINGAL DEPENDENCY – reimplement
        return self
        //return (self as NSString).ows_stripped()
    }
    
    var encodedForSelector: String? {
        guard let shifted = try? self.caesar(shift: selectorOffset) else {
            return nil
        }
        
        guard let data = shifted.data(using: .utf8) else {
            return nil
        }
        
        return data.base64EncodedString()
    }
    
    var decodedForSelector: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        guard let shifted = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return try? shifted.caesar(shift: 127 - selectorOffset)
    }
}

public extension NSString {
    
    @objc
    var encodedForSelector: String? {
        return (self as String).encodedForSelector
    }
    
    @objc
    var decodedForSelector: String? {
        return (self as String).decodedForSelector
    }
}

public extension String {
    
    var filterForDisplay: String? {
        return self
        // MARK: - SINGAL DEPENDENCY – reimplement
        //return (self as NSString).filterStringForDisplay()
    }
    
    // There appears to be a bug in NSBigMutableString that causes a
    // crash when using prefix to (not) truncate long strings to their
    // current length. safePrefix() avoids this crash by only using
    // prefix() if necessary.
    func safePrefix(_ maxLength: Int) -> String {
        guard maxLength < count else {
            return self
        }
        return String(prefix(maxLength))
    }
    
    // Truncates string to be less than or equal to byteCount, while ensuring we never truncate partial characters for multibyte characters.
    func truncated(toByteCount byteCount: UInt) -> String? {
        var lowerBoundCharCount = 0
        var upperBoundCharCount = self.count
        
        while (lowerBoundCharCount < upperBoundCharCount) {
            guard let upperBoundData = safePrefix(upperBoundCharCount).data(using: .utf8) else {
                return nil
            }
            
            if upperBoundData.count <= byteCount {
                break
            }
            
            // converge
            if upperBoundCharCount - lowerBoundCharCount == 1 {
                upperBoundCharCount = lowerBoundCharCount
                break
            }
            
            let midpointCharCount = (lowerBoundCharCount + upperBoundCharCount) / 2
            let midpointString = safePrefix(midpointCharCount)
            
            guard let midpointData = midpointString.data(using: .utf8) else {
                return nil
            }
            let midpointByteCount = midpointData.count
            
            if midpointByteCount < byteCount {
                lowerBoundCharCount = midpointCharCount
            } else {
                upperBoundCharCount = midpointCharCount
            }
        }
        
        return String(safePrefix(upperBoundCharCount))
    }
    
    func replaceCharacters(characterSet: CharacterSet, replacement: String) -> String {
        let components = self.components(separatedBy: characterSet)
        return components.joined(separator: replacement)
    }
    
    func removeCharacters(characterSet: CharacterSet) -> String {
        let components = self.components(separatedBy: characterSet)
        return components.joined()
    }
}
