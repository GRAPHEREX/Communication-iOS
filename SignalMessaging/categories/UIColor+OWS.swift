//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

// MARK: - Color Helpers

@objc
public extension UIColor {

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

    @objc(blendedWithColor:alpha:)
    func blended(with otherColor: UIColor, alpha alphaParam: CGFloat) -> UIColor {
        var r0: CGFloat = 0
        var g0: CGFloat = 0
        var b0: CGFloat = 0
        var a0: CGFloat = 0
        let result0 = self.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        assert(result0)

        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        let result1 = otherColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        assert(result1)

        let alpha = CGFloatClamp01(alphaParam)
        return UIColor(red: CGFloatLerp(r0, r1, alpha),
                       green: CGFloatLerp(g0, g1, alpha),
                       blue: CGFloatLerp(b0, b1, alpha),
                       alpha: CGFloatLerp(a0, a1, alpha))

    }
}

// MARK: - Palette

@objc
public extension UIColor {

    // MARK:- SkyTech
    
    // ACCENT COLORS
    @objc(st_accentGreen)
    class var st_accentGreen: UIColor {
        return UIColor(rgbHex: 0x4BDC9B)
    }
    
    @objc(st_messageGreen)
    class var st_messageGreen: UIColor {
        return UIColor(rgbHex: 0x43C68B)
    }
    
    @objc(st_accentBlack)
    class var st_accentBlack: UIColor {
        return UIColor(rgbHex: 0x030303)
    }
    
    @objc(st_accentWhite)
    class var st_accentWhite: UIColor {
        return UIColor(rgbHex: 0xFFFFFF)
    }
    
    @objc(st_accentGraySmallBackground)
    class var st_accentGraySmallBackground: UIColor {
        return UIColor(rgbHex: 0xF9F9F9)
    }
    
    // NEUTRAL COLORS
    @objc(st_neutralGray)
    class var st_neutralGray: UIColor {
        return UIColor(rgbHex: 0xB3B3B3)
    }
    
    @objc(st_neutralGrayLines)
    class var st_neutralGrayLines: UIColor {
        return UIColor(rgbHex: 0xEBEFF3)
    }
    
    @objc(st_neutralGrayMessege)
    class var st_neutralGrayMessege: UIColor {
        return UIColor(rgbHex: 0xF0F0F0)
    }
    
    @objc(st_neutralGrayBackground)
    class var st_neutralGrayBackground: UIColor {
        return UIColor(rgbHex: 0xF5F5F5)
    }
    
    @objc(st_neutralIcon1)
    class var st_neutralIcon1: UIColor {
        return UIColor(rgbHex: 0x808080)
    }
    
    @objc(st_neutralIcon2)
    class var st_neutralIcon2: UIColor {
        return UIColor(rgbHex: 0xCCCCCC)
    }
    
    // OTHER COLORS
    @objc(st_otherRed)
    class var st_otherRed: UIColor {
        return UIColor(rgbHex: 0xF95148)
    }
    
    @objc(st_otherYellowSearch)
    class var st_otherYellowSearch: UIColor {
        return UIColor(rgbHex: 0xFFD614)
    }
    
    @objc(st_otherYellowIcon)
    class var st_otherYellowIcon: UIColor {
        return UIColor(rgbHex: 0xF5B423)
    }
    
    @objc(st_otherBlueLink)
    class var st_otherBlueLink: UIColor {
        return UIColor(rgbHex: 0x0C12FE)
    }
    
    @objc(st_otherPink)
    class var st_otherPink: UIColor {
        return UIColor(rgbHex: 0xFE9B91)
    }
    
    @objc(st_otherBlue)
    class var st_otherBlue: UIColor {
        return UIColor(rgbHex: 0x6B6BFF)
    }
    
    @objc(st_otherOrange)
    class var st_otherOrange: UIColor {
        return UIColor(rgbHex: 0xFF840C)
    }
    
    @objc(st_otherGreenDark)
    class var st_otherGreenDark: UIColor {
        return UIColor(rgbHex: 0x669073)
    }
    
    // MARK: Brand Colors

    @objc(ows_signalBlueColor)
    class var ows_signalBlue: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(ows_signalBlueDarkColor)
    class var ows_signalBlueDark: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    // MARK: Accent Colors

    /// Nav Bar, Primary Buttons
    @objc(ows_accentBlueColor)
    class var ows_accentBlue: UIColor {
        // Ultramarine UI
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(ows_accentBlueDarkColor)
    class var ows_accentBlueDark: UIColor {
        // Ultramarine UI Light
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    @objc(ows_accentBlueTintColor)
    class var ows_accentBlueTint: UIColor {
        return UIColor(rgbHex: 0x4bdc9b) // it's grapherex green
    }

    /// Making calls, success states
    @objc(ows_accentGreenColor)
    class var ows_accentGreen: UIColor {
        return UIColor(rgbHex: 0x4CAF50)
    }

    /// Warning, update states
    @objc(ows_accentYellowColor)
    class var ows_accentYellow: UIColor {
        return UIColor(rgbHex: 0xFFD624)
    }

    /// Ending calls, error states
    @objc(ows_accentRedColor)
    class var ows_accentRed: UIColor {
        return UIColor(rgbHex: 0xF44336)
    }

    // MARK: - GreyScale

    @objc(ows_whiteColor)
    class var ows_white: UIColor {
        return UIColor(rgbHex: 0xFFFFFF)
    }

    @objc(ows_gray02Color)
    class var ows_gray02: UIColor {
        return UIColor(rgbHex: 0xF6F6F6)
    }

    @objc(ows_gray05Color)
    class var ows_gray05: UIColor {
        return UIColor(rgbHex: 0xE9E9E9)
    }

    @objc(ows_gray10Color)
    class var ows_gray10: UIColor {
        return UIColor(rgbHex: 0xf0f0f0)
    }

    @objc(ows_gray15Color)
    class var ows_gray15: UIColor {
        return UIColor(rgbHex: 0xD4D4D4)
    }

    @objc(ows_gray20Color)
    class var ows_gray20: UIColor {
        return UIColor(rgbHex: 0xCCCCCC)
    }

    @objc(ows_gray25Color)
    class var ows_gray25: UIColor {
        return UIColor(rgbHex: 0xB9B9B9)
    }

    @objc(ows_gray40Color)
    class var ows_gray40: UIColor {
        return UIColor(rgbHex: 0x999999)
    }

    @objc(ows_gray45Color)
    class var ows_gray45: UIColor {
        return UIColor(rgbHex: 0x848484)
    }

    @objc(ows_gray60Color)
    class var ows_gray60: UIColor {
        return UIColor(rgbHex: 0x5E5E5E)
    }

    @objc(ows_gray65Color)
    class var ows_gray65: UIColor {
        return UIColor(rgbHex: 0x4A4A4A)
    }

    @objc(ows_gray75Color)
    class var ows_gray75: UIColor {
        return UIColor(rgbHex: 0x3B3B3B)
    }

    @objc(ows_gray80Color)
    class var ows_gray80: UIColor {
        return UIColor(rgbHex: 0x2E2E2E)
    }

    @objc(ows_gray85Color)
    class var ows_gray85: UIColor {
        return UIColor(rgbHex: 0x23252A)
    }

    @objc(ows_gray90Color)
    class var ows_gray90: UIColor {
        return UIColor(rgbHex: 0x1B1B1B)
    }

    @objc(ows_gray95Color)
    class var ows_gray95: UIColor {
        return UIColor(rgbHex: 0x121212)
    }

    @objc(ows_blackColor)
    class var ows_black: UIColor {
        return UIColor(rgbHex: 0x000000)
    }

    // MARK: Masks

    @objc(ows_whiteAlpha00Color)
    class var ows_whiteAlpha00: UIColor {
        return UIColor(white: 1.0, alpha: 0)
    }

    @objc(ows_whiteAlpha20Color)
    class var ows_whiteAlpha20: UIColor {
        return UIColor(white: 1.0, alpha: 0.2)
    }

    @objc(ows_whiteAlpha25Color)
    class var ows_whiteAlpha25: UIColor {
        return UIColor(white: 1.0, alpha: 0.25)
    }

    @objc(ows_whiteAlpha30Color)
    class var ows_whiteAlpha30: UIColor {
        return UIColor(white: 1.0, alpha: 0.3)
    }

    @objc(ows_whiteAlpha40Color)
    class var ows_whiteAlpha40: UIColor {
        return UIColor(white: 1.0, alpha: 0.4)
    }

    @objc(ows_whiteAlpha60Color)
    class var ows_whiteAlpha60: UIColor {
        return UIColor(white: 1.0, alpha: 0.6)
    }

    @objc(ows_whiteAlpha80Color)
    class var ows_whiteAlpha80: UIColor {
        return UIColor(white: 1.0, alpha: 0.8)
    }

    @objc(ows_whiteAlpha90Color)
    class var ows_whiteAlpha90: UIColor {
        return UIColor(white: 1.0, alpha: 0.9)
    }

    @objc(ows_blackAlpha05Color)
    class var ows_blackAlpha05: UIColor {
        return UIColor(white: 0, alpha: 0.05)
    }

    @objc(ows_blackAlpha20Color)
    class var ows_blackAlpha20: UIColor {
        return UIColor(white: 0, alpha: 0.20)
    }

    @objc(ows_blackAlpha25Color)
    class var ows_blackAlpha25: UIColor {
        return UIColor(white: 0, alpha: 0.25)
    }

    @objc(ows_blackAlpha40Color)
    class var ows_blackAlpha40: UIColor {
        return UIColor(white: 0, alpha: 0.40)
    }

    @objc(ows_blackAlpha60Color)
    class var ows_blackAlpha60: UIColor {
        return UIColor(white: 0, alpha: 0.60)
    }

    @objc(ows_blackAlpha80Color)
    class var ows_blackAlpha80: UIColor {
        return UIColor(white: 0, alpha: 0.80)
    }

    // MARK: UI Colors

    // FIXME OFF-PALETTE
    @objc(ows_reminderYellowColor)
    class var ows_reminderYellow: UIColor {
        return UIColor(rgbHex: 0xFCF0D9)
    }

    // MARK: -

    class func ows_randomColor(isAlphaRandom: Bool) -> UIColor {
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
