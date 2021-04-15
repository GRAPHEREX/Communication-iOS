//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

extension UIImage {
    public static func loadFromWalletBundle(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle.walletBundle, compatibleWith: nil)
    }
}
