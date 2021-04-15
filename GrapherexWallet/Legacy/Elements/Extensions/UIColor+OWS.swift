//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

// MARK: - Color Helpers

@objc
public extension UIColor {

//    @objc(blendedWithColor:alpha:)
//    func blended(with otherColor: UIColor, alpha alphaParam: CGFloat) -> UIColor {
//        var r0: CGFloat = 0
//        var g0: CGFloat = 0
//        var b0: CGFloat = 0
//        var a0: CGFloat = 0
//        let result0 = self.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
//        assert(result0)
//
//        var r1: CGFloat = 0
//        var g1: CGFloat = 0
//        var b1: CGFloat = 0
//        var a1: CGFloat = 0
//        let result1 = otherColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
//        assert(result1)
//
//        let alpha = CGFloatClamp01(alphaParam)
//        return UIColor(red: CGFloatLerp(r0, r1, alpha),
//                       green: CGFloatLerp(g0, g1, alpha),
//                       blue: CGFloatLerp(b0, b1, alpha),
//                       alpha: CGFloatLerp(a0, a1, alpha))
//
//    }
}

// MARK: - Palette

@objc
public extension UIColor {

    // MARK:- SkyTech
    
    @objc(wlt_messageGreen)
    class var wlt_messageGreen: UIColor {
        return UIColor(rgbHex: 0x43C68B)
    }
    
    @objc(wlt_accentBlack)
    class var wlt_accentBlack: UIColor {
        return UIColor(rgbHex: 0x030303)
    }
    
    @objc(wlt_accentWhite)
    class var wlt_accentWhite: UIColor {
        return UIColor(rgbHex: 0xFFFFFF)
    }
    
    @objc(wlt_accentGraySmallBackground)
    class var wlt_accentGraySmallBackground: UIColor {
        return UIColor(rgbHex: 0xF9F9F9)
    }
    
    // NEUTRAL COLORS
    @objc(wlt_neutralGray)
    class var wlt_neutralGray: UIColor {
        return UIColor(rgbHex: 0xB3B3B3)
    }
    
    @objc(wlt_neutralGrayLines)
    class var wlt_neutralGrayLines: UIColor {
        return UIColor(rgbHex: 0xEBEFF3)
    }
    
    @objc(wlt_neutralGrayMessege)
    class var wlt_neutralGrayMessege: UIColor {
        return UIColor(rgbHex: 0xF0F0F0)
    }
    
    @objc(wlt_neutralGrayBackground)
    class var wlt_neutralGrayBackground: UIColor {
        return UIColor(rgbHex: 0xF5F5F5)
    }
    
    @objc(wlt_neutralIcon1)
    class var wlt_neutralIcon1: UIColor {
        return UIColor(rgbHex: 0x808080)
    }
    
    @objc(wlt_neutralIcon2)
    class var wlt_neutralIcon2: UIColor {
        return UIColor(rgbHex: 0xCCCCCC)
    }
    
    // OTHER COLORS
    @objc(wlt_otherRed)
    class var wlt_otherRed: UIColor {
        return UIColor(rgbHex: 0xF95148)
    }
    
    @objc(wlt_otherYellowSearch)
    class var wlt_otherYellowSearch: UIColor {
        return UIColor(rgbHex: 0xFFD614)
    }
    
    @objc(wlt_otherYellowIcon)
    class var wlt_otherYellowIcon: UIColor {
        return UIColor(rgbHex: 0xF5B423)
    }
    
    @objc(wlt_otherBlueLink)
    class var wlt_otherBlueLink: UIColor {
        return UIColor(rgbHex: 0x0C12FE)
    }
    
    @objc(wlt_otherPink)
    class var wlt_otherPink: UIColor {
        return UIColor(rgbHex: 0xFE9B91)
    }
    
    @objc(wlt_otherBlue)
    class var wlt_otherBlue: UIColor {
        return UIColor(rgbHex: 0x6B6BFF)
    }
    
    @objc(wlt_otherOrange)
    class var wlt_otherOrange: UIColor {
        return UIColor(rgbHex: 0xFF840C)
    }
    
    @objc(wlt_otherGreenDark)
    class var wlt_otherGreenDark: UIColor {
        return UIColor(rgbHex: 0x669073)
    }
    
    // MARK: Brand Colors

    @objc(wlt_signalBlueColor)
    class var wlt_signalBlue: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(wlt_signalBlueDarkColor)
    class var wlt_signalBlueDark: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    // MARK: Accent Colors

    /// Nav Bar, Primary Buttons
    @objc(wlt_accentBlueColor)
    class var wlt_accentBlue: UIColor {
        // Ultramarine UI
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(wlt_accentBlueDarkColor)
    class var wlt_accentBlueDark: UIColor {
        // Ultramarine UI Light
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(wlt_accentBlueTintColor)
    class var wlt_accentBlueTint: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    /// Warning, update states
    @objc(wlt_accentYellowColor)
    class var wlt_accentYellow: UIColor {
        return UIColor(rgbHex: 0xFFD624)
    }

    /// Ending calls, error states
    @objc(wlt_accentRedColor)
    class var wlt_accentRed: UIColor {
        return UIColor(rgbHex: 0xF44336)
    }

    // MARK: - GreyScale

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

    // MARK: Masks

    @objc(wlt_whiteAlpha00Color)
    class var wlt_whiteAlpha00: UIColor {
        return UIColor(white: 1.0, alpha: 0)
    }

    @objc(wlt_whiteAlpha20Color)
    class var wlt_whiteAlpha20: UIColor {
        return UIColor(white: 1.0, alpha: 0.2)
    }

    @objc(wlt_whiteAlpha25Color)
    class var wlt_whiteAlpha25: UIColor {
        return UIColor(white: 1.0, alpha: 0.25)
    }

    @objc(wlt_whiteAlpha30Color)
    class var wlt_whiteAlpha30: UIColor {
        return UIColor(white: 1.0, alpha: 0.3)
    }

    @objc(wlt_whiteAlpha40Color)
    class var wlt_whiteAlpha40: UIColor {
        return UIColor(white: 1.0, alpha: 0.4)
    }

    @objc(wlt_whiteAlpha60Color)
    class var wlt_whiteAlpha60: UIColor {
        return UIColor(white: 1.0, alpha: 0.6)
    }

    @objc(wlt_whiteAlpha80Color)
    class var wlt_whiteAlpha80: UIColor {
        return UIColor(white: 1.0, alpha: 0.8)
    }

    @objc(wlt_whiteAlpha90Color)
    class var wlt_whiteAlpha90: UIColor {
        return UIColor(white: 1.0, alpha: 0.9)
    }

    @objc(wlt_blackAlpha05Color)
    class var wlt_blackAlpha05: UIColor {
        return UIColor(white: 0, alpha: 0.05)
    }

    @objc(wlt_blackAlpha20Color)
    class var wlt_blackAlpha20: UIColor {
        return UIColor(white: 0, alpha: 0.20)
    }

    @objc(wlt_blackAlpha25Color)
    class var wlt_blackAlpha25: UIColor {
        return UIColor(white: 0, alpha: 0.25)
    }

    @objc(wlt_blackAlpha40Color)
    class var wlt_blackAlpha40: UIColor {
        return UIColor(white: 0, alpha: 0.40)
    }

    @objc(wlt_blackAlpha60Color)
    class var wlt_blackAlpha60: UIColor {
        return UIColor(white: 0, alpha: 0.60)
    }

    @objc(wlt_blackAlpha80Color)
    class var wlt_blackAlpha80: UIColor {
        return UIColor(white: 0, alpha: 0.80)
    }

    // MARK: UI Colors

    // FIXME OFF-PALETTE
    @objc(wlt_reminderYellowColor)
    class var wlt_reminderYellow: UIColor {
        return UIColor(rgbHex: 0xFCF0D9)
    }

    // MARK: -

    class func wlt_randomColor(isAlphaRandom: Bool) -> UIColor {
        func randomComponent() -> CGFloat {
            let precision: UInt32 = 255
            return CGFloat(arc4random_uniform(precision + 1)) / CGFloat(precision)
        }
        return UIColor(red: randomComponent(),
                       green: randomComponent(),
                       blue: randomComponent(),
                       alpha: isAlphaRandom ? randomComponent() : 1)
    }
}
