//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class TransactionView: BaseView {
    
    enum Constant {
        static let height: CGFloat = 64
        static let margin: CGFloat = 8
    }
    
    private let formatter = MoneyFormatter()
    private let transactionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.primaryTextColor
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14).ows_semibold
        label.numberOfLines = 2
        return label
    }()
    
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        label.textColor = Theme.secondaryTextAndIconColor
        label.textAlignment = .right
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        label.textColor = Theme.primaryTextColor
        label.textAlignment = .right
        return label
    }()
    
    private let indicatorView = UIImageView()
    
    enum TransactionType {
        case all, sent, received
        
        var icon: UIImage? {
            switch self {
            case .sent:
                return #imageLiteral(resourceName: "icon.sent").withRenderingMode(.alwaysTemplate)
            case .received:
                return #imageLiteral(resourceName: "icon.received").withRenderingMode(.alwaysTemplate)
            case .all:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .sent:
                return NSLocalizedString("MAIN_SENT", comment: "")
            case .received:
                return NSLocalizedString("MAIN_RECEIVED", comment: "")
            case .all:
                return NSLocalizedString("MAIN_ALL", comment: "")
            }
        }
        
        var color: UIColor {
            switch self {
            case .sent:
                return .st_otherRed
            case .received:
                return .st_accentGreen
            case .all:
                return .clear
            }
        }
        
        var fieldName: String? {
            switch self {
            case .sent:
                return "out"
            case .received:
                return "in"
            case .all:
                return nil
            }
        }
    }
    
    struct Props {
        let currency: Currency
        let amount: String
        let transactionName: String
        let date: Date
        let type: TransactionType
        let hash: String
        let address: String
    }
    
    var props: Props = Props(currency: Currency.default, amount: "0.0",
                             transactionName: "", date: Date(), type: .sent,
                             hash: "", address: ""
        ) { didSet {
        render()
    }}
    
    override internal func setup() {
        backgroundColor = .clear
        autoSetDimension(.height, toSize: Constant.height)
        
        addSubview(indicatorView)
        indicatorView.autoSetDimensions(to: .init(width: 24, height: 24))
        indicatorView.autoPinLeadingToSuperviewMargin(withInset: 8)
        indicatorView.autoVCenterInSuperview()
        indicatorView.tintColor = Theme.inversedPrimaryTextColor
        
        addSubview(transactionLabel)
        transactionLabel.autoVCenterInSuperview()
        transactionLabel.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 8)
        transactionLabel.setContentHuggingHorizontalLow()
        transactionLabel.setCompressionResistanceHorizontalLow()

        let containerView = UIView()
        addSubview(containerView)
        containerView.autoVCenterInSuperview()
        containerView.autoPinEdge(.leading, to: .trailing, of: transactionLabel, withOffset: 16)
        containerView.autoPinTrailingToSuperviewMargin(withInset: 8)
        containerView.setContentHuggingPriority(.required, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        containerView.addSubview(priceLabel)
        priceLabel.autoPinTopToSuperviewMargin()
        priceLabel.autoPinLeadingAndTrailingToSuperviewMargin()
//        priceLabel.autoPinBottomToSuperviewMargin()
        
        containerView.addSubview(rateLabel)
        rateLabel.autoPinEdge(.top, to: .bottom, of: priceLabel)
        rateLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        rateLabel.autoPinBottomToSuperviewMargin()
        
        formatter.minDecimalDigits = 2
        formatter.decimalDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
    }
}

internal extension TransactionView {
    func render() {
        transactionLabel.text = props.type.title.uppercased()
        priceLabel.textColor = props.type.color
        priceLabel.text = "\(props.amount) \(props.currency.symbol)"
        rateLabel.text = "~ " + formatter.multiply(value1: props.amount, value2: props.currency.rate)! + " " + props.currency.rateSymbol
        indicatorView.image = props.type.icon
        indicatorView.tintColor = props.type.color
    }
}
