//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

extension UIView {
    class func spacer(withWidth width: CGFloat) -> UIView {
        let view = UIView()
        view.autoSetDimension(.width, toSize: width)
        return view
    }
    
    class func spacer(withHeight height: CGFloat) -> UIView {
        let view = UIView()
        view.autoSetDimension(.height, toSize: height)
        return view
    }
}
