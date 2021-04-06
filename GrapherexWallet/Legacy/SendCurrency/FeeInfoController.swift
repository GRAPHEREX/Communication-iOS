//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
import PureLayout

final class FeeInfoController: ActionSheetController {
    
    var message = ""
    
    private let closeButton = UIButton()
    
    override func setup() {
        super.setup()
        isCancelable = true
        stackView.spacing = 40
        setupMargins(margin: 20)
        setupContent()
        setupButton()
    }
}

extension FeeInfoController {
    func setupButton() {
        let height: CGFloat = 56
        closeButton.autoSetDimension(.height, toSize: height)
        closeButton.autoSetDimension(.width, toSize: 200)
        closeButton.layer.cornerRadius = height / 2
        closeButton.clipsToBounds = true
        closeButton.setTitleColor(.white, for: .normal)
//        closeButton.backgroundColor = .stwlt_accentGreen
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.setTitle("Got it", for: .normal)
        closeButton.wltSetContentHuggingVerticalHigh()
        let stack = UIStackView(arrangedSubviews: [UIView.hStretchingSpacer(), closeButton, UIView.hStretchingSpacer()])
        stack.distribution = .equalCentering
        stackView.addArrangedSubview(stack)
    }
    
    func setupContent() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = message
        stackView.addArrangedSubview(titleLabel)
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
