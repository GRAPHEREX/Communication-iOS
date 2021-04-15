//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation

class CurrencyHeaderView: NiblessView {
    // MARK: - Private Properties
    private struct Constants {
        static let imageSize: CGFloat = 60
    }
    
    // MARK: - Coin Balance
    private let coinImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let coinLabel: UILabel = {
        let view = UILabel()
        view.font = .wlt_robotoFont(withSize: 20)
        view.textColor = .wlt_primaryLabelColor
        return view
    }()
    
    private let coinBalanceLabel: UILabel = {
        let view = UILabel()
        view.font = .wlt_robotoFont(withSize: 20)
        view.textColor = .wlt_primaryLabelColor
        return view
    }()
    
    private let currencyBalanceLabel: UILabel = {
        let view = UILabel()
        view.font = .wlt_robotoFont(withSize: 16)
        view.textColor = .wlt_secondaryLabelColor
        return view
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinBalanceLabel, currencyBalanceLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var coinBalanceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coinImage, coinLabel, balanceStack])
        stack.axis = .horizontal
        stack.spacing = 10
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
    
    // MARK: - Price
    private let priceTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 12)
        view.textColor = UIColor.wlt_secondaryLabelColor
        view.textAlignment = .center
        view.text = "BTC dominance".localized
        return view
    }()
    
    private let priceValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.wlt_robotoFont(withSize: 14)
        view.textColor = UIColor.wlt_primaryLabelColor
        view.textAlignment = .center
        return view
    }()
    
    private lazy var priceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceTitleLabel, priceValueLabel])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Market Info
    private lazy var marketInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [marketCapStack, volumeTradeStack, priceStack])
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        return stack
    }()
    
    struct Props {
        let coin: Currency
        let coinBalance: String
        let currencyBalance: String
        let marketCap: String
        let volumeTrade: String
        let price: String
    }
    
    var props: Props? { didSet {
        render()
    }}
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        activateConstraints()
    }
}

fileprivate extension CurrencyHeaderView {
    
    func render() {
        guard let props = props else { return }
        coinLabel.text = props.coin.name
        coinImage.sd_setImage(with: URL(string: props.coin.icon))
        coinBalanceLabel.text = props.coinBalance
        currencyBalanceLabel.text = props.currencyBalance
        marketCapValueLabel.text = props.marketCap
        volumeTradeValueLabel.text = props.volumeTrade
        priceValueLabel.text = props.price
    }
    
    func setup() {
        backgroundColor = UIColor.wlt_primaryBackgroundColor
        
        addSubview(coinBalanceStack)
        addSubview(marketInfoStack)
        
    }
    
    func activateConstraints() {
        coinImage.wltSetContentHuggingHorizontalLow()
        coinImage.autoSetDimension(.height, toSize: Constants.imageSize)
        coinImage.autoMatch(.height, to: .width, of: coinImage)
        coinLabel.wltSetContentHuggingHorizontalHigh()
        
        coinBalanceStack.autoSetDimension(.height, toSize: 80)
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        coinBalanceStack.autoPinEdge(toSuperviewEdge: .top)
        
        marketCapTitleLabel.wltSetContentHuggingVerticalHigh()
        marketCapValueLabel.wltSetContentHuggingVerticalLow()
        
        volumeTradeTitleLabel.wltSetContentHuggingVerticalHigh()
        volumeTradeValueLabel.wltSetContentHuggingVerticalLow()
        
        priceTitleLabel.wltSetContentHuggingVerticalHigh()
        priceValueLabel.wltSetContentHuggingVerticalLow()
        
        marketInfoStack.autoSetDimension(.height, toSize: 60)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        marketInfoStack.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        marketInfoStack.autoPinEdge(.top, to: .bottom, of: coinBalanceStack)

    }
}
