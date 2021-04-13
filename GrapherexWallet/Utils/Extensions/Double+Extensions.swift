//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
