//
//  Copyright (c) 2018 SkyTech. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

public class STSecondaryButton: UIButton {

    enum Constant {
        static let height: CGFloat = 56
        static let radius: CGFloat = 12
    }
    private let image = #imageLiteral(resourceName: "general.icon.enter")
    
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
        layer.cornerRadius = Constant.radius
        // TODO : add color from palette
        addBorder(with: Theme.primaryTextColor)
        setTitleColor(Theme.primaryTextColor, for: .normal)
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        tintColor = .st_accentBlack
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.autoPinTrailing(toEdgeOf: self, offset: -16)
        imageView.autoPinTopToSuperviewMargin()
        imageView.autoPinBottomToSuperviewMargin()
    }
    
}

