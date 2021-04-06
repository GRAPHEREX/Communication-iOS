//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public extension UIView {
    func addBottomStroke() -> UIView {
        return addBottomStroke(color: UIColor.gray, strokeWidth: WLTCGHairlineWidth())
    }
    
    func addBottomStroke(color: UIColor, strokeWidth: CGFloat) -> UIView {
        let strokeView = UIView()
        strokeView.backgroundColor = color
        addSubview(strokeView)
        strokeView.autoSetDimension(.height, toSize: strokeWidth)
        strokeView.wltAutoPinWidthToSuperview()
        strokeView.autoPinEdge(toSuperviewEdge: .bottom)
        return strokeView
    }
}
