//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation
import PureLayout

final class TransactionView: BaseView {
    
    enum Constant {
        static let height: CGFloat = 64
        static let margin: CGFloat = 8
    }
    
    private let formatter = MoneyFormatter()
    private let transactionLabel: UILabel = {
        let label = UILabel()
        // MARK: - SINGAL DEPENDENCY – reimplement
        label.font = .systemFont(ofSize: 14)
//        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14).wlt_semibold
//        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        label.numberOfLines = 2
        return label
    }()
    
    private let rateLabel: UILabel = {
        let label = UILabel()
        // MARK: - SINGAL DEPENDENCY – reimplement
        label.font = .systemFont(ofSize: 12)
//        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 12)
//        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        label.textAlignment = .right
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        // MARK: - SINGAL DEPENDENCY – reimplement
        label.font = .systemFont(ofSize: 14)
//        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
//        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
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
                return .red
            case .received:
                return .green
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
        // MARK: - SINGAL DEPENDENCY – reimplement
//        indicatorView.wltAutoPinLeadingToSuperviewMargin(withInset: 8)
//        indicatorView.wltAutoVCenterInSuperview()
//        indicatorView.tintColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.inversedPrimaryTextColor
        
        addSubview(transactionLabel)
//        transactionLabel.wltAutoVCenterInSuperview()
        transactionLabel.autoPinEdge(.leading, to: .trailing, of: indicatorView, withOffset: 8)
//        transactionLabel.wltSetContentHuggingHorizontalLow()
//        transactionLabel.wltSetCompressionResistanceHorizontalLow()

        let containerView = UIView()
        addSubview(containerView)
//        containerView.wltAutoVCenterInSuperview()
        containerView.autoPinEdge(.leading, to: .trailing, of: transactionLabel, withOffset: 16)
//        containerView.wltAutoPinTrailingToSuperviewMargin(withInset: 8)
        containerView.setContentHuggingPriority(.required, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.required, for: .horizontal)

        containerView.addSubview(priceLabel)
//        priceLabel.wltAutoPinTopToSuperviewMargin()
//        priceLabel.wltAutoPinLeadingAndTrailingToSuperviewMargin()
//        priceLabel.wltAutoPinBottomToSuperviewMargin()
        
        containerView.addSubview(rateLabel)
        rateLabel.autoPinEdge(.top, to: .bottom, of: priceLabel)
//        rateLabel.wltAutoPinLeadingAndTrailingToSuperviewMargin()
//        rateLabel.wltAutoPinBottomToSuperviewMargin()
        
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
