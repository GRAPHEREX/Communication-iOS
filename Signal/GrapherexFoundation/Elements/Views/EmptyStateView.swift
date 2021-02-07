//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

@objc
final class EmptyStateView: UIView {
    typealias VoidHandler = () -> Void
    private let illustrationView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        // TODO: add Color
        label.textColor = .lightGray
        return label
    }()
    
    private let actionButton = UIButton()
    private var action: VoidHandler?
    
    @objc public
    func set(
        image: UIImage?,
        title: String,
        subtitle: String,
        buttonTitle: String,
        action: VoidHandler?
    ) {
        illustrationView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        self.action = action
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
}

fileprivate extension EmptyStateView {
    @objc func didTap() {
        action?()
    }
    
    @objc func applyTheme() {
        backgroundColor = Theme.backgroundColor
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
        backgroundColor = Theme.backgroundColor
        let topSpacer = UIView.vStretchingSpacer()
        let middleSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        illustrationView.contentMode = .scaleAspectFit
        let topTitleSpacer = UIView.vStretchingSpacer()
        let bottomTitleSpacer = UIView.vStretchingSpacer()
        
        let stackView = UIStackView(arrangedSubviews: [
            topSpacer,
            illustrationView,
            topTitleSpacer,
            titleLabel,
            bottomTitleSpacer,
            subtitleLabel,
            middleSpacer,
            actionButton,
            bottomSpacer
        ])
        
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.contentMode = .center
        stackView.autoPinEdgesToSuperviewMargins()
        topTitleSpacer.autoMatch(.height, to: .height, of: self, withMultiplier: 0.05)
        bottomTitleSpacer.autoMatch(.height, to: .height, of: topTitleSpacer, withMultiplier: 0.5)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer, withMultiplier: 0.4)
        middleSpacer.autoMatch(.height, to: .height, of: bottomSpacer, withMultiplier: 1)
        actionButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        illustrationView.autoMatch(.height, to: .height, of: self, withMultiplier: 0.25)
        
        actionButton.titleLabel?.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        actionButton.setTitleColor(Theme.secondaryTextAndIconColor, for: .normal)
    }
}
