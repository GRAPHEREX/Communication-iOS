//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

final public class FontManager {
    
    // MARK: - Private Properties
    private enum frameworkFonts: String, CaseIterable {
        case robotoRegular = "Roboto-Regular"
        case robotoLight = "Roboto-Light"
        case robotoMedium = "Roboto-Medium"
        case robotoBold = "Roboto-Bold"
        case sfUITextRegular = "SFUIText-Regular"
        case sfUITextSemibold = "SFUIText-Semibold"
        
        var fontExtension: String {
            return "ttf"
        }
    }
    
    // MARK: - Private Methods
    private static func fontsURLs() -> [URL] {
        let bundle = Bundle.walletBundle
        let fileNames = frameworkFonts.allCases
        return fileNames.map({ bundle.url(forResource: $0.rawValue, withExtension: $0.fontExtension)! })
    }
    
    private static func registerFont(fromUrl url: URL) throws {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            throw WalletInternalError.fontNotFoundError(url.absoluteString)
        }
        
        let font = CGFont(fontDataProvider)
        var error: Unmanaged<CFError>?
        guard let unwrappedFont = font,
              CTFontManagerRegisterGraphicsFont(unwrappedFont, &error) else {
            if let unwrappedError = error?.takeUnretainedValue() {
                throw WalletInternalError.fontRegistrationError(unwrappedError.localizedDescription)
            } else {
                throw WalletInternalError.fontRegistrationError(url.absoluteString)
            }
        }
    }
    
    // MARK: - Public Methods
    public static func registerCustomFonts() {
        logger.debug("Registering wallet custom fonts")
        
        fontsURLs().forEach({
            do {
                try registerFont(fromUrl: $0)
            } catch {
                // Maybe the font is already registered in the host app so we just log and skip
                logger.error("Registering wallet custom fonts error: \(error.localizedDescription)")
            }
        })
        
        logger.debug("Registering wallet custom fonts finished")
    }
}
