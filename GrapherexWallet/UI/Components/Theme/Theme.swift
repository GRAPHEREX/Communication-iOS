//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

class Theme {
    static var isDarkThemeEnabled: Bool = false {
        didSet {
            NotificationCenter.default.post(name: Notification.themeChanged, object: nil)
        }
    }
        
    static var walletBubbleColor: UIColor {
        return isDarkThemeEnabled ? .wlt_gray95 : .wlt_gray05
    }
    
    static var primarybackgroundColor: UIColor {
        return isDarkThemeEnabled ? .wlt_accentBlack : .wlt_white
    }
    
    static var secondaryBackgroundColor: UIColor {
        return isDarkThemeEnabled ? .wlt_gray80 : .wlt_neutralGrayMessage
    }
    
    static var inversedBackgroundColor: UIColor {
        return isDarkThemeEnabled ? .wlt_white : .wlt_accentBlack
    }
    
    static var navbarBackgroundColor: UIColor {
        return isDarkThemeEnabled ? .wlt_black : .wlt_white
    }
    
    static var navbarTintColor: UIColor {
        return isDarkThemeEnabled ? .wlt_white : .wlt_black
    }
    
    static var secondaryTextAndIconColor: UIColor {
        return isDarkThemeEnabled ? .wlt_gray25 : .wlt_gray116Color
    }
    
    static var primaryTextColor: UIColor {
        return isDarkThemeEnabled ? .wlt_white : .wlt_black 
    }
}
