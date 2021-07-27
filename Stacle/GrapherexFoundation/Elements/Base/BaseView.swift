//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

open class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open func setup() { }
}
