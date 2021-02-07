import Foundation
import UIKit

final class WalletItemCell: UIView {
    
    private let mainImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let iconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextSemiboldFont(withSize: 17).ows_semibold
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = Theme.secondaryTextAndIconColor
        view.font = .st_sfUiTextRegularFont(withSize: 15)
        return view
    }()
    
    private let currencyBalanceLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let changesLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextSemiboldFont(withSize: 12)
        return view
    }()
    
    struct Props {
        let title: String
        let walletId: String
        let currency: Currency
        let currencyIcon: String
        let balance: String
        let currencyBalance: String
        let hasPin: Bool
        let needPassword: Bool
        let isHidden: Bool
    }
    
    var props: Props? { didSet {
        render()
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

fileprivate extension WalletItemCell {
    
    func render() {
        guard let props = props else { return }
        mainImage.sd_setImage(with: URL(string: props.currencyIcon))
        titleLabel.text = props.title
        balanceLabel.text = props.balance
        currencyBalanceLabel.attributedText = props.currencyBalance.decorate(
            primaryAttributes: [
                .font: UIFont.ows_regularFont(withSize: 14),
                .foregroundColor: Theme.primaryTextColor
            ],
            secondaryAttributes: [
                .font: UIFont.ows_regularFont(withSize: 14),
                .foregroundColor: Theme.primaryTextColor
            ]
        )
    }
    
    func setup() {
        backgroundColor = Theme.backgroundColor
        self.layoutMargins = .zero
        
        // Image
        addSubview(mainImage)
        mainImage.autoVCenterInSuperview()
        mainImage.autoSetDimensions(to: .init(width: 48, height: 48))
        mainImage.autoPinTopToSuperviewMargin()
        mainImage.autoPinBottomToSuperviewMargin()
        mainImage.autoPinLeadingToSuperviewMargin()
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            balanceLabel
        ])
        stack.axis = .vertical
        addSubview(stack)
        stack.autoPinEdge(.top, to: .top, of: mainImage, withOffset: 5)
        stack.autoPinEdge(.bottom, to: .bottom, of: mainImage, withOffset: -5)
        stack.autoVCenterInSuperview()
        stack.autoPinEdge(.leading, to: .trailing, of: mainImage, withOffset: 8)

        // Currency Balance
        addSubview(currencyBalanceLabel)
        currencyBalanceLabel.autoVCenterInSuperview()
        currencyBalanceLabel.autoPinEdge(.leading, to: .trailing, of: stack, withOffset: 8, relation: .greaterThanOrEqual)
        currencyBalanceLabel.autoPinTrailingToSuperviewMargin()
        currencyBalanceLabel.setCompressionResistanceHorizontalHigh()
    }
}
