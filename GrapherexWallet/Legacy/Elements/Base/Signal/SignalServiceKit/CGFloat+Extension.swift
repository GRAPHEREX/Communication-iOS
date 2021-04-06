//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public extension CGFloat {
    func clamp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return WLTCGFloatClamp(self, minValue, maxValue)
    }
    
    func clamp01() -> CGFloat {
        return WLTCGFloatClamp01(self)
    }
    
    // Linear interpolation
    func lerp(_ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
        return WLTCGFloatLerp(minValue, maxValue, self)
    }
    
    // Inverse linear interpolation
    func inverseLerp(_ minValue: CGFloat, _ maxValue: CGFloat, shouldClamp: Bool = false) -> CGFloat {
        let value = WLTCGFloatInverseLerp(self, minValue, maxValue)
        return (shouldClamp ? WLTCGFloatClamp01(value) : value)
    }
    
    static let halfPi: CGFloat = CGFloat.pi * 0.5
    
    func fuzzyEquals(_ other: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        return abs(self - other) < tolerance
    }
    
    var square: CGFloat {
        return self * self
    }
}
