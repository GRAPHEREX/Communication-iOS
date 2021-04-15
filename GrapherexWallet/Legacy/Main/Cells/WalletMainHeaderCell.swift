import Foundation
import UIKit

final class WalletMainHeaderCell: UIView {
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 16)
        view.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        view.textAlignment = .center
        return view
    }()
    
    struct Props {
        let balance: String
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

fileprivate extension WalletMainHeaderCell {
    
    func render() {
        guard let props = props else { return }
        balanceLabel.text = props.balance
        balanceLabel.attributedText = props.balance.decorate(
            primaryAttributes: [
                .font: UIFont.wlt_sfUiTextSemiboldFont(withSize: 16),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ],
            secondaryAttributes: [
                .font: UIFont.wlt_sfUiTextSemiboldFont(withSize: 16),
                .foregroundColor: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/
            ]
        )
    }
    
    func setup() {
        backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
        self.autoSetDimension(.height, toSize: 80)
        self.layoutMargins = .zero
        
        addSubview(balanceLabel)
        balanceLabel.wltAutoVCenterInSuperview()
        balanceLabel.wltAutoPinLeadingToSuperviewMargin(withInset: 32)
        balanceLabel.wltAutoPinTrailingToSuperviewMargin(withInset: 32)
        
        let bottomDivider = UIView.spacer(withHeight: 16)
        bottomDivider.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryBackgroundColor.withAlphaComponent(0.5)
        addSubview(bottomDivider)
        bottomDivider.autoPinEdge(toSuperviewEdge: .leading, withInset: 0)
        bottomDivider.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)
        bottomDivider.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
    }
}
