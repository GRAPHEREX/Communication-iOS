//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class CoinDetailsHeaderView: NiblessView {
    
    private enum Constants {
        static let coinImageSize: CGFloat = 40.0
        static let dividerViewHeight: CGFloat = 7.0
        static let horizontalContentOffset: CGFloat = 11.0
        static let verticalContentOffset: CGFloat = 11.0
    }
    
    // MARK: - Coin Balance
    private let coinImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let coinLabel: UILabel = {
        let view = UILabel()
        view.font = .wlt_robotoRegularFont(withSize: 20)
        view.textColor = Theme.primaryTextColor
        return view
    }()
    
    private lazy var coinStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinImage, coinLabel])
        stack.axis = .horizontal
        stack.spacing = 7
        return stack
    }()
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = Theme.primaryTextColor
        view.font = .wlt_robotoMediumFont(withSize: 20)
        view.textAlignment = .right
        return view
    }()
    
    private let currencyBalanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = Theme.secondaryTextAndIconColor
        view.font = .wlt_robotoRegularFont(withSize: 16)
        view.textAlignment = .right
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceLabel, currencyBalanceLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var coinBalanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinStack, balanceStack])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Market Cap
    private let marketCapTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .center
        view.text = "Market cap".localized
        return view
    }()
    
    private let marketCapValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 14)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var marketCapStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapTitleLabel, marketCapValueLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Volume Trade
    private let volumeTradeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .center
        view.text = "Volume trade 24h".localized
        return view
    }()
    
    private let volumeTradeValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 14)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var volumeTradeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [volumeTradeTitleLabel, volumeTradeValueLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Price
    private let priceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .center
        view.text = "Price".localized
        return view
    }()
    
    private let priceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 14)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var priceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceTitleLabel, priceValueLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Market Info
    private lazy var marketInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapStack, volumeTradeStack, priceStack])
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        return stack
    }()
    
    // MARK: - Dividers
    private lazy var bottomDivider: UIView = {
        let bottomDivider = UIView.spacer(withHeight: Constants.dividerViewHeight)
        bottomDivider.backgroundColor = Theme.secondaryBackgroundColor
        return bottomDivider
    }()
    
    struct Props {
        let coinInfo: CoinInfo
//        let balance: String
        let marketCap: String
        let volumeTrade: String
//        let btcDominance: String
//        let spendValue: String
//        let incomeValue: String
//        let spendIncomeProportion: Float
    }
    
    var props: Props? { didSet {
        render()
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        activateConstraints()
    }
}

fileprivate extension CoinDetailsHeaderView {
    
    func render() {
        guard let props = props else { return }
        coinImage.sd_setImage(with: URL(string: props.coinInfo.currency.icon))
        coinLabel.text = props.coinInfo.currency.symbol
        
        balanceLabel.text = props.coinInfo.balance
        currencyBalanceLabel.text = props.coinInfo.currencyBalance
        marketCapValueLabel.text = props.marketCap
        volumeTradeValueLabel.text = props.volumeTrade
        priceValueLabel.text = props.coinInfo.stockPrice
    }
    
    func setup() {
        backgroundColor = Theme.primarybackgroundColor
        
        addSubview(coinBalanceStack)
        addSubview(marketInfoStack)
        addSubview(bottomDivider)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    // MARK: - Constraints Setup
    func activateConstraints() {
        activateConstraintsCoinBalance()
        activateConstraintsMarketInfo()
        activateConstraintsDivider()
    }
    
    func activateConstraintsCoinBalance() {
        coinBalanceStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: Constants.verticalContentOffset, left: Constants.horizontalContentOffset, bottom: Constants.verticalContentOffset, right: Constants.horizontalContentOffset))
        
        coinImage.wltSetContentHuggingHorizontalHigh()
        coinImage.autoSetDimension(.height, toSize: Constants.coinImageSize)
        coinImage.autoMatch(.height, to: .width, of: coinImage)
        coinLabel.wltSetContentHuggingHorizontalLow()
    }
    
    func activateConstraintsMarketInfo() {
        marketInfoStack.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(.top, to: .bottom, of: coinBalanceStack, withOffset: 15)
    }
    
    func activateConstraintsDivider() {
        bottomDivider.autoPinEdge(toSuperviewEdge: .leading)
        bottomDivider.autoPinEdge(toSuperviewEdge: .trailing)
        bottomDivider.autoPinEdge(toSuperviewEdge: .bottom)
        bottomDivider.autoPinEdge(.top, to: .bottom, of: marketInfoStack, withOffset: 8)
    }
    
    // MARK: - Theme
    @objc private func onThemeChanged() {
        backgroundColor = Theme.primarybackgroundColor
        coinLabel.textColor = Theme.primaryTextColor
        balanceLabel.textColor = Theme.primaryTextColor
        currencyBalanceLabel.textColor = Theme.secondaryTextAndIconColor
        
        marketCapTitleLabel.textColor = Theme.primaryTextColor
        volumeTradeTitleLabel.textColor = Theme.primaryTextColor
        priceTitleLabel.textColor = Theme.primaryTextColor
        
        marketCapValueLabel.textColor = Theme.secondaryTextAndIconColor
        volumeTradeValueLabel.textColor = Theme.secondaryTextAndIconColor
        priceValueLabel.textColor = Theme.secondaryTextAndIconColor
        
        bottomDivider.backgroundColor = Theme.secondaryBackgroundColor
    }
}


