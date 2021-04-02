//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class ExchangeHistoryView: BaseView {
    enum Constant {
        static let height: CGFloat = 64
        static let layoutMargin: CGFloat = 16
        static let changeViewLayoutMargin: CGFloat = 4
    }
    
    struct Props {
        enum Changes {
            case income(String)
            case loss(String)
            
            var icon: UIImage {
                switch self {
                case .income(_):
                    return #imageLiteral(resourceName: "icon.up")
                case .loss(_):
                    return #imageLiteral(resourceName: "icon.down")
                }
            }
            
            var color: UIColor {
                switch self {
                case .income(_):
                    return .st_accentGreen
                case .loss(_):
                    return .st_otherRed
                }
            }
            
            var changes: String {
                switch self {
                case .income(let change):
                    return change
                case .loss(let change):
                    return change
                }
            }
        }
        
        enum Status: String, CaseIterable {
            case pending, closed
        }
        
        let fromCurrency: Currency
        let toCurrency: Currency
        let price: String
        let changes: Changes
        let status: Status
    }
    
    var props: Props = Props(fromCurrency: Currency.default, toCurrency: Currency.default, price: "", changes: .income(""), status: .pending) {
        didSet {
            render()
        }
    }
    
    private let indicatorView = UIImageView()
    private let exchangeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "icon.exchange").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Theme.secondaryTextAndIconColor
        return imageView
    }()
    
    private let fromCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 14)
        return label
    }()
    
    private let toCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 14)
        return label
    }()
    
    private let coefLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.secondaryTextAndIconColor
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        return label
    }()
    
    private let changeView = UIView()
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.backgroundColor
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 12)
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 12)
        return label
    }()
    
    
    override func setup() {
        super.setup()
        configure()
    }
    
    private func configure() {
        layoutMargins = .init(top: Constant.layoutMargin, leading: Constant.layoutMargin,
                              bottom: Constant.layoutMargin, trailing: Constant.layoutMargin)
        
        addSubview(indicatorView)
        indicatorView.autoPinEdge(toSuperviewMargin: .top)
        indicatorView.autoPinEdge(toSuperviewMargin: .leading)
        
        changeView.layer.cornerRadius = changeLabel.font.lineHeight / 2
        changeView.addSubview(changeLabel)
        changeView.layoutMargins = .init(top: Constant.changeViewLayoutMargin / 2, left: Constant.changeViewLayoutMargin,
                                         bottom: Constant.changeViewLayoutMargin / 2, right: Constant.changeViewLayoutMargin)
        changeLabel.autoPinEdgesToSuperviewMargins()
        
        priceLabel.textAlignment = .right
        
        let topStack = UIStackView(arrangedSubviews: [fromCurrencyLabel, exchangeImageView, toCurrencyLabel, UIView.hStretchingSpacer(), changeView])
        let bottomStack = UIStackView(arrangedSubviews: [coefLabel, UIView.hStretchingSpacer(), priceLabel])
        let mainContentView = UIStackView(arrangedSubviews: [topStack, bottomStack])
        mainContentView.axis = .vertical
        mainContentView.spacing = 4
        
        addSubview(mainContentView)
        mainContentView.autoPinTopToSuperviewMargin()
        mainContentView.autoPinBottomToSuperviewMargin()
        mainContentView.autoPinTrailingToSuperviewMargin()
        mainContentView.autoPinLeading(toTrailingEdgeOf: indicatorView)
    }
    
}

fileprivate extension ExchangeHistoryView {
    func render() {
        priceLabel.text = props.price
        coefLabel.text = "100.00 ETH * 100"
        changeLabel.text = props.changes.changes
        indicatorView.tintColor = props.changes.color
        changeView.backgroundColor = props.changes.color
        toCurrencyLabel.text = props.toCurrency.symbol
        fromCurrencyLabel.text = props.fromCurrency.symbol
        indicatorView.image = props.changes.icon.withRenderingMode(.alwaysTemplate)
    }
}
