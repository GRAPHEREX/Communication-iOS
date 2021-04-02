//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import CoreImage

private class GrapherexWalletBundleClass { }

extension UIImage {
    func parseQR() -> [String] {
        guard let image = CIImage(image: self) else {
            return []
        }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: image) ?? []
        
        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }
    }
    
    public static func image(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: GrapherexWalletBundleClass.self), compatibleWith: nil)
    }
}
