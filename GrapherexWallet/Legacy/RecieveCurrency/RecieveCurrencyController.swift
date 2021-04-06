//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class ReceiveCurrencyController: ActionSheetController {
    
    enum Constants {
        static let margin: CGFloat = 16
    }
    
    private let copyButton = STPrimaryButton()
    var wallet: Wallet!
    
    override func setup() {
        super.setup()
        
        isCancelable = true
        stackView.spacing = 4
        setupMargins(margin: Constants.margin)
        setupCenterHeader(title: NSLocalizedString("MAIN_RECEIVE", comment: ""), close: #selector(close))
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        setupCodeView()
        setupCodeInfo()
        setupButton()
    }
}

fileprivate extension ReceiveCurrencyController {
    func setupButton() {
        copyButton.addTarget(self, action: #selector(copyButtonTap), for: .touchUpInside)
        copyButton.setTitle(NSLocalizedString("MAIN_COPY", comment: ""), for: .normal)
        copyButton.wltSetContentHuggingVerticalHigh()
        copyButton.icon = .copy
        stackView.addArrangedSubview(copyButton)
        copyButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setupCodeView() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 18).wlt_semibold
        titleLabel.textAlignment = .center
        titleLabel.wltSetContentHuggingVerticalHigh()
        titleLabel.text = "\(wallet.credentials?.name ?? wallet.currency.symbol) address"
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 4, maxHeight: 16))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 8, maxHeight: 32))
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.minificationFilter = .nearest
        imageView.layer.magnificationFilter = .nearest
        stackView.addArrangedSubview(imageView)
        imageView.autoMatch(.height, to: .height, of: view, withMultiplier: 0.34)
        imageView.image = QRCreator.createQr(qrString: wallet.address, size: UIScreen.main.bounds.size.height * 0.34)
        stackView.addArrangedSubview(UIView.vStretchingSpacer(minHeight: 8, maxHeight: 16))
    }
    
    func setupCodeInfo() {
        let topSpacer = UIView.hStretchingSpacer()
        let middleSpacer = UIView.hStretchingSpacer()
        let bottomSpacer = UIView.hStretchingSpacer()
        
        stackView.addArrangedSubview(topSpacer)
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "This address only supports \(wallet.currency.symbol) \nand Omni USDT. Deposit will arrive after \nat least 3 block confirmations"
        stackView.addArrangedSubview(titleLabel)
        titleLabel.autoMatch(.width, to: .width, of: view, withOffset: -2*Constants.margin)
        stackView.addArrangedSubview(middleSpacer)
        
        let codeLabel = UILabel()
        codeLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        codeLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16).wlt_semibold
        codeLabel.textAlignment = .center
        codeLabel.text = wallet.address
        codeLabel.numberOfLines = 0
        stackView.addArrangedSubview(codeLabel)
        stackView.addArrangedSubview(bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
        topSpacer.autoMatch(.height, to: .height, of: middleSpacer)
    }
    
    @objc
    func copyButtonTap() {
        copyButton.handleEnabled(true)
        copyButton.setTitle(NSLocalizedString("USER_ID_VIEW_COPY_BUTTON_TITLE_AFTER_CLICK", comment: ""), for: .normal)
        UIPasteboard.general.string = wallet.address
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion:  nil)
    }
}
