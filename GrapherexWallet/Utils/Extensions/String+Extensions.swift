//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension String {
    func removingTrailingSlash() -> String {
        if last == "/" {
            return String(self.dropLast())
        }
        return self
    }
}
