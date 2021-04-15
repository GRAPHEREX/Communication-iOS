import Foundation
import UIKit

final class WalletCell: UIView {
    
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
        view.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 17).wlt_semibold
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        view.font = .wlt_sfUiTextRegularFont(withSize: 15)
        return view
    }()
    
    private let currencyBalanceLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private let changesLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 12)
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

fileprivate extension WalletCell {
    
    func render() {
        guard let props = props else { return }
        mainImage.sd_setImage(with: URL(string: props.currencyIcon))
        titleLabel.text = props.title
        balanceLabel.text = props.balance
        currencyBalanceLabel.attributedText = props.currencyBalance.decorate(
            primaryAttributes: [
                .font: UIFont.wlt_regularFont(withSize: 14),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ],
            secondaryAttributes: [
                .font: UIFont.wlt_regularFont(withSize: 14),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ]
        )
    }
    
    func setup() {
        backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        self.layoutMargins = .zero
        
        // Image
        addSubview(mainImage)
        mainImage.wltAutoVCenterInSuperview()
        mainImage.autoSetDimensions(to: .init(width: 48, height: 48))
        mainImage.wltAutoPinTopToSuperviewMargin()
        mainImage.wltAutoPinBottomToSuperviewMargin()
        mainImage.wltAutoPinLeadingToSuperviewMargin()
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            balanceLabel
        ])
        stack.axis = .vertical
        addSubview(stack)
        stack.autoPinEdge(.top, to: .top, of: mainImage, withOffset: 5)
        stack.autoPinEdge(.bottom, to: .bottom, of: mainImage, withOffset: -5)
        stack.wltAutoVCenterInSuperview()
        stack.autoPinEdge(.leading, to: .trailing, of: mainImage, withOffset: 8)

        // Currency Balance
        addSubview(currencyBalanceLabel)
        currencyBalanceLabel.wltAutoVCenterInSuperview()
        currencyBalanceLabel.autoPinEdge(.leading, to: .trailing, of: stack, withOffset: 8, relation: .greaterThanOrEqual)
        currencyBalanceLabel.wltAutoPinTrailingToSuperviewMargin()
        currencyBalanceLabel.wltSetCompressionResistanceHorizontalHigh()
    }
}
