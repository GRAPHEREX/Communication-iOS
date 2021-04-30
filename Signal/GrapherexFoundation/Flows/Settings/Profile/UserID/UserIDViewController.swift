//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

@objc
final class UserIDViewController: OWSViewController {
    
    static let kIPhone5ScreenWidth: CGFloat = 320.0;
    static let kIPhone7PlusScreenWidth: CGFloat = 414.0;
    var address: SignalServiceAddress?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = NSLocalizedString("USER_ID_VIEW_COPY_MAIN_TITLE", comment: "")
        label.textColor = Theme.primaryTextColor;
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        return label
    }()
    
    private let userIDLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        label.textAlignment = .center
        label.textColor = Theme.primaryTextColor
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let instructionsLabel: UILabel = {
       let label = UILabel()
        label.text = NSLocalizedString("USER_ID_VIEW_COPY_LABEL_INFO", comment: "")
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        label.textColor = Theme.primaryTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let copyButton: STPrimaryButton = {
        let button = STPrimaryButton()
        button.handleEnabled(false)
        button.icon = .copy
        button.isEnabled = true
        button.setTitle(NSLocalizedString("USER_ID_VIEW_COPY_BUTTON_TITLE_NORMAL", comment: ""), for: .normal)
        return button
    }()
    
    private var qrUuidCodeView = UIImageView()
    
    override func loadView() {
        super.loadView()
        self.view = UIView()
        self.view.backgroundColor = Theme.backgroundColor
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("MAIN_USER_ID", comment: "")

        let qrImageSize: CGFloat = UIScreen.main.bounds.size.height * 0.33
        if address?.isMyAddress == true {
            titleLabel.text = NSLocalizedString("USER_ID_VIEW_COPY_MAIN_TITLE", comment: "")
            userIDLabel.text = TSAccountManager.localAddress?.uuidString
            self.qrUuidCodeView.image = QRCreator.createQr(qrString: TSAccountManager.localAddress?.uuidString, size: qrImageSize)
        } else if let address = address {
            titleLabel.text = String(format: NSLocalizedString("USER_ID_VIEW_COPY_MAIN_TITLE_SOMEONE", comment: ""),
                                     arguments: [Environment.shared.contactsManager.displayName(for: address)])
            self.qrUuidCodeView.image = QRCreator.createQr(qrString: address.uuidString, size: qrImageSize)
        
            userIDLabel.text = address.uuidString ?? "nil"
        } else {
            self.qrUuidCodeView.image = QRCreator.createQr(qrString: TSAccountManager.localAddress?.uuidString, size: qrImageSize)
            userIDLabel.text = "nil"
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                                target: self,
                                                                action: #selector(closeButton))
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action,
                                                              target: self,
                                                              action: #selector(didTapShare(_:)))]
        
    }
    
    override func setup() {
        view.layoutMargins = .init(top: ScaleFromIPhone5To7Plus(iPhone5Value: 16.0, iPhone7PlusValue: 20.0), left: 16, bottom: 0, right: 16)
        
        view.addSubview(titleLabel)
        titleLabel.autoHCenterInSuperview()
        titleLabel.autoPinTopToSuperviewMargin()
        
        view.addSubview(qrUuidCodeView)
        qrUuidCodeView.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        qrUuidCodeView.autoMatch(.height, to: .height, of: self.view, withMultiplier: 0.33)
        qrUuidCodeView.autoMatch(.width, to: .height, of: qrUuidCodeView)
        qrUuidCodeView.layer.magnificationFilter = .nearest
        qrUuidCodeView.layer.minificationFilter = .nearest
        qrUuidCodeView.autoHCenterInSuperview()
        view.addSubview(qrUuidCodeView)
        
        view.addSubview(userIDLabel)
        userIDLabel.autoHCenterInSuperview()
        userIDLabel.autoPinEdge(.top, to: .bottom, of: qrUuidCodeView, withOffset: 16)
        userIDLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        
        view.addSubview(instructionsLabel)
        instructionsLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        instructionsLabel.autoPinEdge(.top, to: .bottom, of: userIDLabel, withOffset: 16)
        
        view.addSubview(copyButton)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.autoPinLeadingToSuperviewMargin()
        copyButton.autoPinTrailingToSuperviewMargin()
        copyButton.autoPin(toBottomLayoutGuideOf: self, withInset: 56)
    }

    override func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
    }
}

fileprivate extension UserIDViewController {
    
    @objc func closeButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ScaleFromIPhone5To7Plus(iPhone5Value:CGFloat,  iPhone7PlusValue:CGFloat) -> CGFloat
    {
        let applicationShortDimension = min(CurrentAppContext().frame.size.width,
                                            CurrentAppContext().frame.size.height)
        return round(CGFloatLerp(iPhone5Value,
                                 iPhone7PlusValue,
                                 CGFloatClamp01(
                                    CGFloatInverseLerp(
                                        applicationShortDimension,
                                        UserIDViewController.kIPhone5ScreenWidth,
                                        UserIDViewController.kIPhone7PlusScreenWidth
                                    )
        )));
    }
    
    @objc func copyButtonTapped() {
        copyButton.handleEnabled(true)
        copyButton.setTitle(NSLocalizedString("USER_ID_VIEW_COPY_BUTTON_TITLE_AFTER_CLICK", comment: ""), for: .normal)
        UIPasteboard.general.string = address?.isMyAddress == true
            ? TSAccountManager.localAddress!.uuidString!
            : (address?.uuidString ?? "nil")
    }
}

private extension UserIDViewController {
    @objc
    func didTapShare(_ sender: UIBarButtonItem) {
        let logText = address?.isMyAddress == true
            ? TSAccountManager.localAddress!.uuidString!
            : (address?.uuidString ?? "nil")
        let vc = UIActivityViewController(activityItems: [logText], applicationActivities: [])
        present(vc, animated: true)
    }
}
