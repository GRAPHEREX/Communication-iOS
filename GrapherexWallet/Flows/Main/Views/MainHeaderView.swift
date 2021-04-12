//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

final class MainHeaderView: NiblessView {
    
    // MARK: - Balance
    private let balanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 16)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .left
        view.text = "Total balance".localized
        return view
    }()
    
    private let balanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 30)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .right
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceTitleLabel, balanceValueLabel])
        stack.axis = .horizontal
        return stack
    }()
    
    // MARK: - Market Cap
    private let marketCapTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "Market cap".localized
        return view
    }()
    
    private let marketCapValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var marketCapStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapTitleLabel, marketCapValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Volume Trade
    private let volumeTradeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "Volume trade 24h".localized
        return view
    }()
    
    private let volumeTradeValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var volumeTradeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [volumeTradeTitleLabel, volumeTradeValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - BTC Dominance
    private let btcDominanceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "BTC dominance".localized
        return view
    }()
    
    private let btcDominanceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var btcDominanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [btcDominanceTitleLabel, btcDominanceValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Market Info
    private lazy var marketInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapStack, volumeTradeStack, btcDominanceStack])
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        return stack
    }()
    
    // MARK: - TableHeaderView
    private let tableCurrencyLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .center
        view.text = "Currency".localized
        return view
    }()
    
    private let tableBalanceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .center
        view.text = "Balance".localized
        return view
    }()
    
    private let tablePriceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_darkGray47Color
        view.textAlignment = .center
        view.text = "Price".localized
        return view
    }()
    
    private lazy var tableHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tableCurrencyLabel, tableBalanceLabel, tablePriceLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var bottomDivider: UIView = {
        let bottomDivider = UIView.spacer(withHeight: 7)
        bottomDivider.backgroundColor = UIColor.color(withRed: 235, green: 235, blue: 235, alpha: 1)
        return bottomDivider
    }()
    
    struct Props {
        let balance: String
        let marketCap: String
        let volumeTrade: String
        let btcDominance: String
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

fileprivate extension MainHeaderView {
    
    func render() {
        guard let props = props else { return }
        balanceValueLabel.text = props.balance
        marketCapValueLabel.text = props.marketCap
        volumeTradeValueLabel.text = props.volumeTrade
        btcDominanceValueLabel.text = props.btcDominance
    }
    
    func setup() {
        backgroundColor = UIColor.wlt_primaryBackgroundColor
        
        addSubview(balanceStack)
        addSubview(marketInfoStack)
        addSubview(tableHeaderStack)
        addSubview(bottomDivider)
    }
    
    func activateConstraints() {
        balanceTitleLabel.wltSetContentHuggingHorizontalHigh()
        balanceValueLabel.wltSetContentHuggingHorizontalLow()
        balanceStack.autoSetDimension(.height, toSize: 80)
        balanceStack.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        balanceStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        balanceStack.autoPinEdge(toSuperviewEdge: .top)
        
        marketCapTitleLabel.wltSetContentHuggingVerticalHigh()
        marketCapValueLabel.wltSetContentHuggingVerticalLow()
        
        btcDominanceTitleLabel.wltSetContentHuggingVerticalHigh()
        btcDominanceValueLabel.wltSetContentHuggingVerticalLow()
        
        volumeTradeTitleLabel.wltSetContentHuggingVerticalHigh()
        volumeTradeValueLabel.wltSetContentHuggingVerticalLow()
        
        marketInfoStack.autoSetDimension(.height, toSize: 60)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        marketInfoStack.autoPinEdge(.top, to: .bottom, of: balanceStack)
        
        bottomDivider.autoPinEdge(toSuperviewEdge: .leading)
        bottomDivider.autoPinEdge(toSuperviewEdge: .trailing)
        bottomDivider.autoPinEdge(.top, to: .bottom, of: marketInfoStack)
        
        tableHeaderStack.autoSetDimension(.height, toSize: 50)
        tableHeaderStack.autoPinEdge(.top, to: .bottom, of: bottomDivider)
        tableHeaderStack.autoPinEdge(toSuperviewEdge: .leading)
        tableHeaderStack.autoPinEdge(toSuperviewEdge: .trailing)
        tableHeaderStack.autoPinEdge(toSuperviewEdge: .bottom)
    }
}

