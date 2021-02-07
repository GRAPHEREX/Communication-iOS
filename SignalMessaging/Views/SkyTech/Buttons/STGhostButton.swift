//
//  Copyright (c) 2018 SkyTech. All rights reserved.
// 

import Foundation
import PromiseKit
import UIKit

public class STGhostButton: UIButton {

    enum Constant {
        static let height: CGFloat = 56
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width,
                      height: Constant.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = Constant.height / 2
        // TODO : add color from palette
        setTitleColor(.gray, for: .normal)
    }
}
