//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//
import Foundation

final class ProfileOptionView: BaseView {
    typealias VoidHandler = () -> Void
    enum Constant {
        static let buttonSize: CGFloat = 40
        static let height: CGFloat = 64
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let mainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .st_accentGreen
        return button
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.buttonSize,
                      height: Constant.height)
    }
    
    enum Option: String {
        // for conversation
        case message = "Message"
        case savedMessage = "Saved message"
        case call = "Call"
        case video = "Video"
        case search = "Search"
        case userId = "User Id"
        // for wallet
        case send = "Send"
        case receive = "Receive"
        case info = "Info"
        case leaveGroup = "Leave Group"
        case gallery = "Gallery"
        
        var iconValue: UIImage? {
            switch self {
            case .send:
                return UIImage(imageLiteralResourceName: "general.icon.enter")
            case .receive:
                return UIImage(imageLiteralResourceName: "profileMenu.icon.plus")
            case .savedMessage:
                return UIImage(imageLiteralResourceName: "profileMenu.icon.message")
            case .message, .call, .video, .search, .info:
                return UIImage(imageLiteralResourceName: "profileMenu.icon.\(self.rawValue.lowercased())")
            case .leaveGroup:
                return UIImage(imageLiteralResourceName: "profileMenu.icon.leave")
            case .userId:
                return UIImage(imageLiteralResourceName: "icon.scan.qr")
            case .gallery:
                return UIImage(imageLiteralResourceName: "icon.album")
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
        mainButton.autoHCenterInSuperview()
        mainButton.autoPinEdge(.top, to: .top, of: self)
        mainButton.layer.cornerRadius = Constant.buttonSize / 2
        mainButton.autoSetDimensions(to: .init(square: Constant.buttonSize))
        mainButton.addTarget(self, action: #selector(didButtonTap), for: .touchUpInside)
        
        addSubview(titleLabel)
        titleLabel.autoHCenterInSuperview()
        titleLabel.autoPinEdge(.top, to: .bottom, of: mainButton)
        titleLabel.autoPinEdge(.bottom, to: .bottom, of: self)
        titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 0, relation: .equal)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: 0, relation: .equal)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
}

fileprivate extension ProfileOptionView {
    func render() {
        let image = option.iconValue?.withRenderingMode(.alwaysTemplate)
        mainButton.setImage(image, for: .normal)
        mainButton.tintColor = Theme.backgroundColor
        titleLabel.text = option.rawValue
    }
    
    @objc func didButtonTap() {
        action()
    }
    
    @objc func applyTheme() {
        render()
    }
}
