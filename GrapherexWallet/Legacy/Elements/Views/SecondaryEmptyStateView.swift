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
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        label.textColor = .stwlt_neutralGray
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
        backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
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
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(applyTheme),
//                                               name: .ThemeDidChange, object: nil)
    }
    
    @objc
    func applyTheme() {
        backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
    }
}
