//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class WalletHeaderView: BaseView {
    
    enum Constact {
        static let imageSize: CGFloat = 60
        static let height: CGFloat = 270
    }
    
    private let mainContentStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private let optionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 40
        return stack
    }()
    
    internal let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    internal let currencyAmountLabel = UILabel()
    
    internal let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 18)
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        return label
    }()
    
    struct Props {
        let currency: Currency
        let amount: String
        let currencyAmount: String
        let options: [ProfileOptionView]
        
        init(currency: Currency,
             amount: String,
             currencyAmount: String,
             options: [ProfileOptionView]) {
            self.currency = currency
            self.amount = amount
            self.currencyAmount = currencyAmount
            self.options = options
        }
    }
    
    private (set) var props: Props?
    
    override func setup() {
        render()
        addSubview(mainContentStack)
        mainContentStack.autoPinEdge(.trailing, to: .trailing, of: self)
        mainContentStack.autoPinEdge(.leading, to: .leading, of: self)
        mainContentStack.autoPinEdge(.top, to: .top, of: self, withOffset: 24)
        mainContentStack.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -24)
        imageView.autoSetDimensions(to: .init(square: Constact.imageSize))
        imageView.layer.cornerRadius = Constact.imageSize / 2
        
        mainContentStack.addArrangedSubview(imageView)
        mainContentStack.setCustomSpacing(16, after: imageView)
        
        mainContentStack.addArrangedSubview(amountLabel)
        
        mainContentStack.addArrangedSubview(currencyAmountLabel)
        mainContentStack.setCustomSpacing(16, after: currencyAmountLabel)
        
        mainContentStack.addArrangedSubview(optionStack)
    }
    
    func setup(currency: Currency,
               amount: String,
               currencyAmount: String,
               options: [ProfileOptionView]) {
        props = Props(
            currency: currency,
            amount: amount,
            currencyAmount: currencyAmount,
            options: options
        )
        render()
    }
    
}

internal extension WalletHeaderView {
    @objc
    func render() {
        backgroundColor = .clear
        guard let props = props else { return }
        
        imageView.sd_setImage(with: URL(string: props.currency.icon), completed: nil)
        currencyAmountLabel.attributedText = props.currencyAmount.decorate(
            primaryAttributes: [
                .font: UIFont.systemFont(ofSize: 16), //UIFont.wlt_sfUiTextRegularFont(withSize: 16),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ],
            secondaryAttributes: [
                .font: UIFont.systemFont(ofSize: 16), //UIFont.wlt_sfUiTextRegularFont(withSize: 16),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ]
        )
        amountLabel.text = props.amount
        amountLabel.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        optionStack.arrangedSubviews
            .forEach({ $0.removeFromSuperview() })
        for option in props.options {
            optionStack.addArrangedSubview(option)
        }
    }
}
