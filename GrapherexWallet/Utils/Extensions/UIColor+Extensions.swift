//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Colors
extension UIColor {
    // MARK: - Labels
    static var wlt_primaryLabelColor: UIColor {
        return .black
    }
    
    static var wlt_secondaryLabelColor: UIColor {
        return color(withRed: 122, green: 122, blue: 122, alpha: 1)
    }
    
    // MARK: - Backgrounds
    static var wlt_primaryBackgroundColor: UIColor {
        return .white
    }
    
    static var wlt_secondaryBackgroundColor: UIColor {
        return UIColor(red: 245, green: 245, blue: 245, alpha: 1)
    }
}

// MARK: - Utils
extension UIColor {
    static func color(withRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
