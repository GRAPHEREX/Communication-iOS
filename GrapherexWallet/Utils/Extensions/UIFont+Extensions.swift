//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    // MARK: - Roboto font
    static func wlt_robotoRegularFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size)!
    }
    
    static func wlt_robotoLightFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Light", size: size)!
    }
    
    static func wlt_robotoMediumFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: size)!
    }
    
    static func wlt_robotoBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: size)!
    }
    
    // MARK: - San Francisco font
    static func wlt_sfUiTextRegularFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Regular", size: size)!
    }
    
    static func wlt_sfUiTextSemiboldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Semibold", size: size)!
    }
}
