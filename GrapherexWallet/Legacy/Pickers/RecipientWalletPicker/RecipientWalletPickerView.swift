import Foundation
import UIKit
import PureLayout

final class RecipientWalletPickerView: UIView {
    typealias FinishHandler = (RecipientWallet) -> Void
    
    public var finish: FinishHandler?
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
    
    private let addressLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        view.font = .stwlt_sfUiTextRegularFont(withSize: 15)
        return view
    }()
    
    private let changesLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextSemiboldFont(withSize: 12)
        return view
    }()
    
    var recipientWallet: RecipientWallet? { didSet {
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

fileprivate extension RecipientWalletPickerView {
    
    func render() {
        guard let wallet = recipientWallet else { return }
        mainImage.sd_setImage(with: URL(string: wallet.currency.icon))
        titleLabel.text = wallet.currency.name
        addressLabel.text = wallet.address
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
            addressLabel
        ])
        stack.axis = .vertical
        addSubview(stack)
        stack.autoPinEdge(.top, to: .top, of: mainImage, withOffset: 5)
        stack.autoPinEdge(.bottom, to: .bottom, of: mainImage, withOffset: -5)
        stack.wltAutoVCenterInSuperview()
        stack.autoPinEdge(.leading, to: .trailing, of: mainImage, withOffset: 8)
        stack.wltAutoPinTrailingToSuperviewMargin()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    @objc
    func tap() {
        guard let recipientWallet = self.recipientWallet else { return }
        finish?(recipientWallet)
    }
}
