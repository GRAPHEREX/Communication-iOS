//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class CoinDetailsHeaderView: NiblessView {
    
    private enum Constants {
        static let coinImageSize: CGFloat = 40.0
        static let coinBalanceViewHeight: CGFloat = 44.0
        static let dividerViewHeight: CGFloat = 7.0
        static let horizontalContentOffset: CGFloat = 16.0
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
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    struct Props {
        let info: CoinWalletsInfo
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
        coinImage.sd_setImage(with: URL(string: props.info.coinIcon))
        coinLabel.text = props.info.coinName
        
        balanceLabel.text = props.info.totalBalance
        currencyBalanceLabel.text = props.info.totalCurrencyBalance
        marketCapValueLabel.text = props.info.marketCap
        volumeTradeValueLabel.text = props.info.volumeTrade
        priceValueLabel.text = props.info.price
    }
    
    func setup() {
        backgroundColor = Theme.primarybackgroundColor
        
        addSubview(coinBalanceStack)
        addSubview(marketInfoStack)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    // MARK: - Constraints Setup
    func activateConstraints() {
        activateConstraintsCoinBalance()
        activateConstraintsMarketInfo()
    }
    
    func activateConstraintsCoinBalance() {
//        coinBalanceStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: Constants.verticalContentOffset, left: Constants.horizontalContentOffset, bottom: Constants.verticalContentOffset, right: Constants.horizontalContentOffset))
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .top, withInset: Constants.verticalContentOffset)
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.horizontalContentOffset)
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.horizontalContentOffset)
        
        coinImage.wltSetContentHuggingHorizontalHigh()
        coinImage.autoSetDimension(.height, toSize: Constants.coinImageSize)
        coinImage.autoMatch(.height, to: .width, of: coinImage)
        coinLabel.wltSetContentHuggingHorizontalLow()
    }
    
    func activateConstraintsMarketInfo() {
        marketInfoStack.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(.top, to: .bottom, of: coinBalanceStack, withOffset: 15)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .bottom)
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
    }
}


