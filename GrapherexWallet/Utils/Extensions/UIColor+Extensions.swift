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
    
    static var wlt_darkGray47Color: UIColor {
        return color(withRed: 47, green: 47, blue: 47, alpha: 1)
    }
    
    static var wlt_darkGray63Color: UIColor {
        return color(withRed: 63, green: 63, blue: 63, alpha: 1)
    }
    
    // MARK: - Backgrounds
    static var wlt_primaryBackgroundColor: UIColor {
        return .white
    }
    
    static var wlt_secondaryBackgroundColor: UIColor {
        return UIColor(red: 235, green: 235, blue: 235, alpha: 1)
    }
}

// MARK: - Utils
extension UIColor {
    static func color(withRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
