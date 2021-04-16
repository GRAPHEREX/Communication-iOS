//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

typealias ActionHandler = () -> Void

class WalletActionView: NiblessView {
    //MARK: - Private Properties
    private struct Constants {
        static let buttonSize: CGFloat = 40
        static let width: CGFloat = 40
        static let height: CGFloat = 64
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.wlt_sfUiTextRegularFont(withSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let mainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Theme.accentGreenColor
        return button
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constants.width,
                      height: Constants.height)
    }
    
    enum Option: String, CustomStringConvertible {
        case send = "Send"
        case receive = "Receive"
        case newWallet = "New Wallet"
        case settings = "Settings"
        
        var iconValue: UIImage? {
            switch self {
            case .send:
                return UIImage.loadFromWalletBundle(named: "general.icon.enter")
            case .receive:
                return UIImage.loadFromWalletBundle(named: "profileMenu.icon.plus")
            case .newWallet:
                return UIImage.loadFromWalletBundle(named: "profileMenu.icon.message")
            case .settings:
                return UIImage.loadFromWalletBundle(named: "icon.album")
            }
        }
        
        var description: String {
            return rawValue.localized
        }
    }
    
    var option: Option {
        didSet {
            render()
        }
    }
    let action: ActionHandler
    
    init(option: Option, action: @escaping ActionHandler) {
        self.option = option
        self.action = action
        super.init(frame: .zero)
        
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        activateConstraints()
        render()
    }
    
    func setup() {
        addSubview(mainButton)
        mainButton.layer.cornerRadius = Constants.buttonSize / 2
        mainButton.addTarget(self, action: #selector(didButtonTap), for: .touchUpInside)
        
        addSubview(titleLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applyTheme), name: Notification.themeChanged, object: nil)
    }
    
    func activateConstraints() {
        mainButton.wltAutoHCenterInSuperview()
        mainButton.autoPinEdge(.top, to: .top, of: self)
        mainButton.autoSetDimensions(to: .init(square: Constants.buttonSize))
        
        titleLabel.wltAutoHCenterInSuperview()
        titleLabel.autoPinEdge(.top, to: .bottom, of: mainButton)
        titleLabel.autoPinEdge(.bottom, to: .bottom, of: self)
        titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 0, relation: .equal)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: 0, relation: .equal)
    }
}

fileprivate extension WalletActionView {
    func render() {
        let image = option.iconValue?.withRenderingMode(.alwaysTemplate)
        mainButton.setImage(image, for: .normal)
        mainButton.tintColor = Theme.primarybackgroundColor
        mainButton.backgroundColor = Theme.accentGreenColor
        titleLabel.text = option.description
    }
    
    @objc func didButtonTap() {
        action()
    }
    
    @objc func applyTheme() {
        render()
    }
}
