//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

public extension UIView {
    func addBottomStroke() -> UIView {
        return addBottomStroke(color: Theme.middleGrayColor, strokeWidth: CGHairlineWidth())
    }
    
    func addBottomStroke(color: UIColor, strokeWidth: CGFloat) -> UIView {
        let strokeView = UIView()
        strokeView.backgroundColor = color
        addSubview(strokeView)
        strokeView.autoSetDimension(.height, toSize: strokeWidth)
        strokeView.autoPinWidthToSuperview()
        strokeView.autoPinEdge(toSuperviewEdge: .bottom)
        return strokeView
    }
}
