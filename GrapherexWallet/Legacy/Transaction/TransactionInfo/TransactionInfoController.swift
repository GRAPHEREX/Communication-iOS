//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class TransactionInfoController: ActionSheetController {
    enum Constants {
        static let margin: CGFloat = 16.0
    }
    
    struct Config {
        let isRecieved: Bool
        let address: String
        let amount: String
        let currency: Currency
        let date: String
        let hash: String
    }
    
    var config: Config!
    
    override func setup() {
        super.setup()
        setupContent()
        setupMargins(margin: Constants.margin)
        isCancelable = true
    }
}

fileprivate extension TransactionInfoController {
    func setupContent() {
        setupCenterHeader(title: "Transaction Info", close: #selector(close))
        makeView(title: "Currency", subtitle: config.currency.name)
        makeView(title: "Amount", subtitle: config.amount)
        makeView(title: "Address of \(config.isRecieved ? "sender" : "recipient")", subtitle: config.address)
        makeView(title: "Date", subtitle: config.date)
        makeView(title: "Hash", subtitle: config.hash, action: #selector(hashTap))
    }
    
    func makeView(title: String, subtitle: String, action: Selector? = nil) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        if action != nil {
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action!))
        }
        
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        titleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 14)
        titleLabel.text = title
        
        backgroundView.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .top, of: backgroundView, withOffset: 4)
        titleLabel.autoPinEdge(.leading, to: .leading, of: backgroundView)
        titleLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundView)
        
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._robotoRegularFont(withSize: 16).wlt_semibold
        subtitleLabel.text = subtitle
        subtitleLabel.autoSetDimension(.width, toSize: UIScreen.main.bounds.size.width - 2*Constants.margin)
        
        backgroundView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 8)
        subtitleLabel.autoPinEdge(.leading, to: .leading, of: backgroundView)
        subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundView)
        subtitleLabel.autoPinEdge(.bottom, to: .bottom, of: backgroundView, withOffset: -4)
        
        stackView.addArrangedSubview(backgroundView)
    }
    
    @objc
    func hashTap() {
        UIPasteboard.general.string = config.hash
        self.presentToast(text: "Hash was copied", fromViewController: self)
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion:  nil)
    }
}
