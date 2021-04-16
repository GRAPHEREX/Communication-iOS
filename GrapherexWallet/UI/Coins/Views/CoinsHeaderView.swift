//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class CoinsHeaderView: NiblessView {
    
    private struct Constants {
        static let currencyFlagSize: CGFloat = 36.0
        static let totalBalanceHeaderHeight: CGFloat = 110.0
        static let dividerViewHeight: CGFloat = 7.0
        static let horizontalContentOffset: CGFloat = 11.0
        static let verticalContentOffset: CGFloat = 11.0
        static let spendIncomeProgressViewHeight: CGFloat = 6.0
    }
    // MARK: - Balance
    private let currencyFlagImage: UIImageView = {
        let view = UIImageView()
        //TODO: Remove this when new API is introduced
        view.image = UIImage.loadFromWalletBundle(named: "staticImages/usaFlag")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let balanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 14)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .left
        view.text = "Total balance".localized
        return view
    }()
    
    private let balanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 18)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .right
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currencyFlagImage, balanceTitleLabel, balanceValueLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    // MARK: - Spend & Income
    private let spendTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoBoldFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .left
        view.text = "spend".localized
        return view
    }()
    
    private let spendValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .left
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private let incomeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoBoldFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .right
        view.text = "income".localized
        return view
    }()
    
    private let incomeValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .right
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var spendIncomeLabelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [spendTitleLabel, spendValueLabel, incomeTitleLabel, incomeValueLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let spendIncomeProgressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = Theme.secondaryTextAndIconColor
        view.trackTintColor = Theme.accentGreenColor
        return view
    }()
    
    private lazy var spendIncomeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [spendIncomeLabelStack, spendIncomeProgressView])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()
    
    private lazy var balanceSpendIncomeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceStack, spendIncomeStack])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var balanceTopView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.secondaryBackgroundColor
        view.clipsToBounds = true
        view.roundCorners(radius: 10)
        return view
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
    
    // MARK: - BTC Dominance
    private let btcDominanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoMediumFont(withSize: 12)
        view.textColor = Theme.primaryTextColor
        view.textAlignment = .center
        view.text = "BTC dominance".localized
        return view
    }()
    
    private let btcDominanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoRegularFont(withSize: 14)
        view.textColor = Theme.secondaryTextAndIconColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var btcDominanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [btcDominanceTitleLabel, btcDominanceValueLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Market Info
    private lazy var marketInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapStack, volumeTradeStack, btcDominanceStack])
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
        let balance: String
        let marketCap: String
        let volumeTrade: String
        let btcDominance: String
        let spendValue: String
        let incomeValue: String
        let spendIncomeProportion: Float
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

fileprivate extension CoinsHeaderView {
    
    func render() {
        guard let props = props else { return }
        balanceValueLabel.text = props.balance
        marketCapValueLabel.text = props.marketCap
        volumeTradeValueLabel.text = props.volumeTrade
        btcDominanceValueLabel.text = props.btcDominance
        spendValueLabel.text = props.spendValue
        incomeValueLabel.text = props.incomeValue
        spendIncomeProgressView.progress = props.spendIncomeProportion
    }
    
    func setup() {
        backgroundColor = Theme.primarybackgroundColor
        
        balanceTopView.addSubview(balanceSpendIncomeStack)
        addSubview(balanceTopView)
        addSubview(marketInfoStack)
        addSubview(bottomDivider)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onThemeChanged), name: Notification.themeChanged, object: nil)
    }
    
    // MARK: - Constraints Setup
    func activateConstraints() {
        activateConstraintsTopBalance()
        activateConstraintsMarketInfo()
        activateConstraintsDivider()
    }
    
    func activateConstraintsTopBalance() {
        currencyFlagImage.wltSetContentHuggingHorizontalHigh()
        currencyFlagImage.wltSetCompressionResistanceHorizontalHigh()
        balanceTitleLabel.wltSetContentHuggingHorizontalHigh()
        balanceTitleLabel.wltSetCompressionResistanceHorizontalHigh()
        balanceValueLabel.wltSetContentHuggingHorizontalLow()
        balanceValueLabel.wltSetCompressionResistanceHorizontalHigh()
        
        balanceTopView.autoSetDimension(.height, toSize: Constants.totalBalanceHeaderHeight)
        balanceTopView.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.horizontalContentOffset)
        balanceTopView.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.horizontalContentOffset)
        balanceTopView.autoPinEdge(toSuperviewEdge: .top, withInset: Constants.verticalContentOffset)
        
        balanceSpendIncomeStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 18, left: 10, bottom: 16, right: 10))
        
        spendIncomeProgressView.autoSetDimension(.height, toSize: Constants.spendIncomeProgressViewHeight)
    }
    
    func activateConstraintsMarketInfo() {
        marketInfoStack.autoPinEdge(toSuperviewEdge: .leading, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: Constants.horizontalContentOffset)
        marketInfoStack.autoPinEdge(.top, to: .bottom, of: balanceTopView, withOffset: 15)
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
        balanceTopView.backgroundColor = Theme.secondaryBackgroundColor
        
        balanceTitleLabel.textColor = Theme.primaryTextColor
        balanceValueLabel.textColor = Theme.primaryTextColor
        spendTitleLabel.textColor = Theme.primaryTextColor
        incomeTitleLabel.textColor = Theme.primaryTextColor
        marketCapTitleLabel.textColor = Theme.primaryTextColor
        volumeTradeTitleLabel.textColor = Theme.primaryTextColor
        btcDominanceTitleLabel.textColor = Theme.primaryTextColor
        
        spendValueLabel.textColor = Theme.secondaryTextAndIconColor
        incomeValueLabel.textColor = Theme.secondaryTextAndIconColor
        marketCapValueLabel.textColor = Theme.secondaryTextAndIconColor
        volumeTradeValueLabel.textColor = Theme.secondaryTextAndIconColor
        btcDominanceValueLabel.textColor = Theme.secondaryTextAndIconColor
        spendIncomeProgressView.progressTintColor = Theme.secondaryTextAndIconColor
        spendIncomeProgressView.trackTintColor = Theme.accentGreenColor
        
        bottomDivider.backgroundColor = Theme.secondaryBackgroundColor
    }
}

