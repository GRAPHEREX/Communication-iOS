//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

@objc
final class SecondaryEmptyStateView: UIView {
    private let illustrationView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .wlt_robotoRegularFont(withSize: 14)
        label.textColor = Theme.secondaryTextAndIconColor
        return label
    }()
    
    @objc public
    func set(
        image: UIImage?,
        title: String
    ) {
        illustrationView.image = image
        titleLabel.text = title
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

fileprivate extension SecondaryEmptyStateView {
    func setup() {
        backgroundColor = Theme.primarybackgroundColor
        illustrationView.contentMode = .scaleAspectFit
        let stackView = UIStackView(arrangedSubviews: [
            illustrationView,
            titleLabel
        ])
        addSubview(stackView)
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.contentMode = .center
        stackView.autoCenterInSuperview()
        stackView.autoPinEdgesToSuperviewMargins(with: UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20))
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: Notification.themeChanged, object: nil)
    }
    
    @objc
    private func themeDidChange() {
        backgroundColor = Theme.primarybackgroundColor
    }
}
