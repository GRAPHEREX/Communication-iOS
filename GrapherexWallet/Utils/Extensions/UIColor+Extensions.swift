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
        return color(withRed: 121, green: 121, blue: 121, alpha: 1)
    }
    
    // MARK: - Named "one value" colors
    static var wlt_darkGray47Color: UIColor {
        return color(withRed: 47, green: 47, blue: 47, alpha: 1)
    }
    
    static var wlt_darkGray58Color: UIColor {
        return color(withRed: 58, green: 58, blue: 58, alpha: 1)
    }
    
    static var wlt_darkGray63Color: UIColor {
        return color(withRed: 63, green: 63, blue: 63, alpha: 1)
    }
    
    static var wlt_darkGray86Color: UIColor {
        return color(withRed: 86, green: 86, blue: 86, alpha: 1)
    }
    
    static var wlt_gray116Color: UIColor {
        return color(withRed: 116, green: 116, blue: 116, alpha: 1)
    }
    
    static var wlt_gray101Color: UIColor {
        return color(withRed: 101, green: 101, blue: 101, alpha: 1)
    }
    
    static var wlt_beige245Color: UIColor {
        return color(withRed: 245, green: 245, blue: 245, alpha: 1)
    }
    
    // MARK: - Backgrounds
    static var wlt_primaryBackgroundColor: UIColor {
        return .white
    }
    
    static var wlt_secondaryBackgroundColor: UIColor {
        return UIColor(red: 235, green: 235, blue: 235, alpha: 1)
    }
    
    // MARK: - Price Changes
    @objc(wlt_positiveChangeColor)
    class var wlt_positiveChangeColor: UIColor {
        return UIColor(rgbHex: 0x4BDC9B)
    }
    
    @objc(wlt_negativeChangeColor)
    class var wlt_negativeChangeColor: UIColor {
        return UIColor(rgbHex: 0xAE2411)
    }
    
    // MARK: - Accent Colors
    @objc(wlt_accentGreen)
    class var wlt_accentGreen: UIColor {
        return UIColor(rgbHex: 0x4BDC9B)
    }
    
    @objc(wlt_accentBlack)
    class var wlt_accentBlack: UIColor {
        return UIColor(rgbHex: 0x030303)
    }
    
    // MARK: - GrayScale
    
    @objc(wlt_whiteColor)
    class var wlt_white: UIColor {
        return UIColor(rgbHex: 0xFFFFFF)
    }
    
    @objc(wlt_gray02Color)
    class var wlt_gray02: UIColor {
        return UIColor(rgbHex: 0xF6F6F6)
    }
    
    @objc(wlt_gray05Color)
    class var wlt_gray05: UIColor {
        return UIColor(rgbHex: 0xE9E9E9)
    }
    
    @objc(wlt_gray10Color)
    class var wlt_gray10: UIColor {
        return UIColor(rgbHex: 0xf0f0f0)
    }
    
    @objc(wlt_gray15Color)
    class var wlt_gray15: UIColor {
        return UIColor(rgbHex: 0xD4D4D4)
    }
    
    @objc(wlt_gray20Color)
    class var wlt_gray20: UIColor {
        return UIColor(rgbHex: 0xCCCCCC)
    }
    
    @objc(wlt_gray25Color)
    class var wlt_gray25: UIColor {
        return UIColor(rgbHex: 0xB9B9B9)
    }
    
    @objc(wlt_gray40Color)
    class var wlt_gray40: UIColor {
        return UIColor(rgbHex: 0x999999)
    }
    
    @objc(wlt_gray45Color)
    class var wlt_gray45: UIColor {
        return UIColor(rgbHex: 0x848484)
    }
    
    @objc(wlt_gray60Color)
    class var wlt_gray60: UIColor {
        return UIColor(rgbHex: 0x5E5E5E)
    }
    
    @objc(wlt_gray65Color)
    class var wlt_gray65: UIColor {
        return UIColor(rgbHex: 0x4A4A4A)
    }
    
    @objc(wlt_gray75Color)
    class var wlt_gray75: UIColor {
        return UIColor(rgbHex: 0x3B3B3B)
    }
    
    @objc(wlt_gray80Color)
    class var wlt_gray80: UIColor {
        return UIColor(rgbHex: 0x2E2E2E)
    }
    
    @objc(wlt_gray85Color)
    class var wlt_gray85: UIColor {
        return UIColor(rgbHex: 0x23252A)
    }
    
    @objc(wlt_gray90Color)
    class var wlt_gray90: UIColor {
        return UIColor(rgbHex: 0x1B1B1B)
    }
    
    @objc(wlt_gray95Color)
    class var wlt_gray95: UIColor {
        return UIColor(rgbHex: 0x121212)
    }
    
    @objc(wlt_blackColor)
    class var wlt_black: UIColor {
        return UIColor(rgbHex: 0x000000)
    }
    
    @objc(wlt_neutralGrayMessage)
    class var wlt_neutralGrayMessage: UIColor {
        return UIColor(rgbHex: 0xF0F0F0)
    }
    
    @objc(wlt_neutralGray)
    class var wlt_neutralGray: UIColor {
        return UIColor(rgbHex: 0xB3B3B3)
    }
}

// MARK: - Utils
extension UIColor {
    static func color(withRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    @objc(colorWithRGBHex:)
    class func color(rgbHex: UInt) -> UIColor {
        return UIColor(rgbHex: rgbHex)
    }
    
    convenience init(rgbHex value: UInt) {
        let red = CGFloat(((value >> 16) & 0xff)) / 255.0
        let green = CGFloat(((value >> 8) & 0xff)) / 255.0
        let blue = CGFloat(((value >> 0) & 0xff)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}
