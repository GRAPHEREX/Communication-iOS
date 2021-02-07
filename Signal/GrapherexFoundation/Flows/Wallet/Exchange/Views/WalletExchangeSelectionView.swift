import UIKit

final class WalletExchangeSelectionView: UIView {
    
    var onRecalculate: ((String) -> Void)?
    
    public var changeWalletAction: (() -> Void)?
    
    public static let height: CGFloat = 120
    
    private let mainImage = AvatarImageView()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        view.textColor = Theme.primaryTextColor
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextRegularFont(withSize: 12)
        view.textColor = Theme.secondaryTextAndIconColor
        return view
    }()
    
    private let arrowImage: UIImageView = {
        let view = UIImageView.withTemplateImage(
            UIImage(named: "profileMenu.icon.arrow"),
            tintColor: UIColor.color(rgbHex: 0xcccccc)
        )
        return view
    }()
    
    private let amountTextField: MoneyInputTextField = {
        let textField = MoneyInputTextField()
        textField.textAlignment = .center
        return textField
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.secondaryTextAndIconColor
        return view
    }()
    
    private let hintAmount: UILabel = {
        let view = UILabel()
        view.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        view.textColor = Theme.secondaryTextAndIconColor
        return view
    }()
    
    private var wallet: Wallet? { didSet {
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
    
    func configure(_ wallet: Wallet) {
        self.wallet = wallet
        
        alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
            self.render()
        }
    }
    
    func getCurrentAmount() -> String {
        return amountTextField.amountForSending() ?? "0"
    }
    
    func getCurrentWallet() -> Wallet? {
        return wallet
    }
    
    func getFormatAmount()  -> String {
        return amountTextField.text ?? "0"
    }
    
    func update(_ wallet: Wallet) {
        self.wallet = wallet
        alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
            self.render()
        }
        onRecalculate?(getCurrentAmount())
    }
    
    func update(_ amount: String) {
        amountTextField.setNewValue(amount, handleOnAmountChange: false)
    }
    
    var isNotEmptyAmount: Bool {
        return amountTextField.isNotEmpty
    }
    
    public
    func setNewValue(value: String, multiplier: String) {
        amountTextField.setNewValue(value, multiplier: multiplier)
    }
    
    public
    func setNewValue(value: String, divider: String) {
        amountTextField.setNewValue(value, divider: divider)
    }
}

fileprivate extension WalletExchangeSelectionView {
    
    @objc
    func applyTheme() {
        titleLabel.textColor = Theme.primaryTextColor
        hintAmount.textColor = Theme.secondaryTextAndIconColor
        backgroundColor = Theme.backgroundColor
    }
    
    func render() {
        guard let wallet = self.wallet else { return }
    
        amountTextField.maxDigitsCountAfterSeparator = wallet.currency.decimalDigits
                
        mainImage.sd_setImage(with: URL(string: wallet.currency.icon), completed: nil)
        titleLabel.text = wallet.currency.name
        balanceLabel.text = wallet.balance
        hintAmount.text = NSLocalizedString("MAIN_AMOUNT", comment: "")
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
        
        backgroundColor = Theme.backgroundColor

        addSubview(mainImage)
        addSubview(arrowImage)
        addSubview(amountTextField)
        addSubview(divider)
        addSubview(hintAmount)

        // Image
        mainImage.autoPinEdge(toSuperviewMargin: .top)
        mainImage.autoPinLeadingToSuperviewMargin(withInset: 16)
        
        // Title & Balance
        let stack = UIStackView(arrangedSubviews: [titleLabel, balanceLabel])
        stack.axis = .vertical
        
        addSubview(stack)
        stack.autoPinEdge(.top, to: .top, of: mainImage, withOffset: 4)
        stack.autoPinEdge(.bottom, to: .bottom, of: mainImage, withOffset: -4 )
        stack.autoPinEdge(.leading, to: .trailing, of: mainImage, withOffset: 12)
        
        // Arrow
        arrowImage.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 8)
        arrowImage.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        amountTextField.autoPinEdge(.top, to: .bottom, of: balanceLabel, withOffset: 16)
        amountTextField.autoHCenterInSuperview()

        divider.autoPinEdge(.top, to: .bottom, of: amountTextField, withOffset: 8)
        divider.autoHCenterInSuperview()

        hintAmount.autoPinEdge(.top, to: .bottom, of: divider, withOffset: 8)
        hintAmount.autoHCenterInSuperview()
        hintAmount.autoPinBottomToSuperviewMargin()
        
        NSLayoutConstraint.activate([
            arrowImage.centerYAnchor.constraint(equalTo: mainImage.centerYAnchor),
            mainImage.heightAnchor.constraint(equalToConstant: 48),
            mainImage.widthAnchor.constraint(equalToConstant: 48),
            
            arrowImage.heightAnchor.constraint(equalToConstant: 24),
            arrowImage.widthAnchor.constraint(equalToConstant: 24),
                        
            amountTextField.widthAnchor.constraint(equalToConstant: 240),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.widthAnchor.constraint(equalToConstant: 240)
        ])
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonDidTap)))
        
        /// Set initial
        titleLabel.text = "Choose wallet"
        mainImage.image = #imageLiteral(resourceName: "icon.question")
        amountTextField.onAmountChange = { [weak self] newValue in
            self?.onRecalculate?(newValue)
        }
    }
    
    @objc
    func buttonDidTap() {
        changeWalletAction?()
    }
}
