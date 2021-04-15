//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

typealias VoidHandler = () -> Void

class WalletActionView: NiblessView {
    //MARK: - Private Properties
    private struct Constants {
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
        button.backgroundColor = .wlt_accentGreen
        return button
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constants.width,
                      height: Constants.height)
    }
    
    enum Option: String {
        case send = "Send"
        case receive = "Receive"
        case newWallet = "New Wallet"
        case settings = "Settings"
        
        var iconValue: UIImage? {
            switch self {
            case .send:
                return UIImage.image(named: "general.icon.enter")
            case .receive:
                return UIImage.image(named: "profileMenu.icon.plus")
            case .newWallet:
                return UIImage.image(named: "profileMenu.icon.message")
            case .settings:
                return UIImage.image(named: "icon.album")
            }
        }
    }
    
    var option: Option! {
        didSet {
            render()
        }
    }
    var action: VoidHandler!
    
    convenience init(option: Option, action: @escaping VoidHandler) {
        self.init()
        self.option = option
        self.action = action
        render()
    }
    
    override func setup() {
        super.setup()
        
        addSubview(mainButton)
        mainButton.wltAutoHCenterInSuperview()
        mainButton.autoPinEdge(.top, to: .top, of: self)
        mainButton.layer.cornerRadius = Constants.buttonSize / 2
        mainButton.autoSetDimensions(to: .init(square: Constant.buttonSize))
        mainButton.addTarget(self, action: #selector(didButtonTap), for: .touchUpInside)
        
        addSubview(titleLabel)
        titleLabel.wltAutoHCenterInSuperview()
        titleLabel.autoPinEdge(.top, to: .bottom, of: mainButton)
        titleLabel.autoPinEdge(.bottom, to: .bottom, of: self)
        titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 0, relation: .equal)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: 0, relation: .equal)
        
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(applyTheme),
        //                                               name: .ThemeDidChange, object: nil)
    }
}

fileprivate extension WalletActionView {
    func render() {
        let image = option.iconValue?.withRenderingMode(.alwaysTemplate)
        mainButton.setImage(image, for: .normal)
        mainButton.tintColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        titleLabel.text = option.rawValue
    }
    
    @objc func didButtonTap() {
        action()
    }
    
    @objc func applyTheme() {
        render()
    }
}
