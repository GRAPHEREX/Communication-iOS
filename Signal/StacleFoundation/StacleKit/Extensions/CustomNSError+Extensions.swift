//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension CustomNSError where Self: RawRepresentable, RawValue: FixedWidthInteger {

    public init?(_ error: Error) {
        let error = error as NSError
        guard error.domain == Self.errorDomain else {
            return nil
        }
        self.init(rawValue: RawValue(error.code))
    }

    public static func ~= (_ some: Self, _ other: Error) -> Bool {
        Self(other)?.errorCode == some.errorCode
    }
}

