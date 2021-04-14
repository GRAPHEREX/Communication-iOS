//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation
import PromiseKit

final class SendCurrencyFromWalletController: OWSViewController {
    
    private let tableViewController = OWSTableViewController()
    private var bottomSpace: CGFloat = 0
    
    private var addressIsValid: Bool = false { didSet {
            handlePrimaryButtonState()
        }}
    private var amountIsValid: Bool = false { didSet {
        handlePrimaryButtonState()
    }}
    private var feeIsValid: Bool = false { didSet {
        handlePrimaryButtonState()
    }}

    private let addressTextField = UITextField()
    private let addressButton = UIButton()
    private let errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.textColor = .st_otherRed
        errorLabel.font = UIFont.st_robotoRegularFont(withSize: 14).ows_semibold
        return errorLabel
    }()
    
    private var feeLabel: UILabel!
    private var feeEquivalentLabel: UILabel!
    
    private let feeButton = UIButton()
    private let feeTextField = MoneyInputTextField()

    private var isRateActive: Bool = false
    private let changeAmountButton = UIButton()
    private var amountSymbolLabel: UILabel!
    private let amountTextField = MoneyInputTextField()
    private var amountTextFieldWidthConstraint: NSLayoutConstraint!
    private var rateAmountSymbolLabel: UILabel!
    private let rateAmountTextField = MoneyInputTextField()
    private var rateAmountTextFieldWidthConstraint: NSLayoutConstraint!
    
    private let tagTextField = UITextField()

    private let sendButton = STPrimaryButton()
    private let amountStack = UIStackView()

    private lazy var textFields: [UITextField] = [
        addressTextField,
        feeTextField,
        amountTextField,
        rateAmountTextField,
        tagTextField,
        gasPriceTextField,
        gasLimitTextField
    ]
    
    var wallet: Wallet!
    
    private let gasPriceTextField = MoneyInputTextField()
    private let gasLimitTextField = MoneyInputTextField()
    private var isEtherium: Bool {
        return wallet.currency.name.lowercased() == SpecialCurrency.ethereum.rawValue
    }

    let formatter = MoneyFormatter()
    let usdFormatter: MoneyFormatter =  {
        let formatter = MoneyFormatter()
        formatter.minDecimalDigits = 2
        formatter.decimalDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
        return formatter
    }()

    private var feeType: FeeType = .default { didSet {
        if isEtherium { setupContent() }
        switch feeType {
        case .default:
            feeIsValid = true
            feeLabel.text = wallet.currency.baseFee
            feeEquivalentLabel.text = (usdFormatter.multiply(value1: wallet.currency.baseFee, value2: wallet.currency.rate) ?? "0") + " " + wallet.currency.rateSymbol
            feeTextField.text = "Default"
            feeTextField.isUserInteractionEnabled = false
        case .personal:
            feeTextField.text = isEtherium ? "Custom" : nil
            feeLabel.text = "0,0"
            feeEquivalentLabel.text = nil
            feeTextField.isUserInteractionEnabled = isEtherium ? false : true
            feeIsValid = feeTextField.text?.isNotZero == true
        }
        self.offErrorState()
        guard let backgroundView = self.feeTextField.superview?.superview else { return }
        backgroundView.backgroundColor = feeType == .default ? .clear : Theme.walletBubbleColor
    }}
    
    private var balance: String {
        balance(for: isRateActive)
    }
    
    private func balance(for isRateActive: Bool) -> String {
        if isRateActive {
            return "~ "
                + (usdFormatter.multiply(value1: wallet.balance, value2: wallet.currency.rate) ?? "0")
                + " " + wallet.currency.rateSymbol
        } else {
            return wallet.balance + " " + wallet.currency.symbol
        }
    }
    
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    override func setup() {
        super.setup()
        
        let window = UIApplication.shared.keyWindow
        let bottom = (window?.safeAreaInsets.bottom ?? 8)
        bottomSpace = bottom >= 8 ? bottom : 8
        
        setupTableView()
        setupElements()
        setupContent()
        title = NSLocalizedString("MAIN_SEND", comment: "")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
        AnalyticsService.log(event: .moneySendScreenOpenedFromWallet, parameters: nil)
    }
    
}

extension SendCurrencyFromWalletController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        if textField === addressTextField {
            addressIsValid = !newText.isEmpty
        }
        
        return true
    }
}

fileprivate extension SendCurrencyFromWalletController {
    func setupElements() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        feeLabel = self.parameterTitle()
        feeEquivalentLabel = self.parameterTitle()
        feeEquivalentLabel.textColor = Theme.primaryTextColor
        feeEquivalentLabel.font = UIFont.st_robotoRegularFont(withSize: 14).ows_semibold
        
        gasLimitTextField.maxDigitsCountAfterSeparator = 0
        gasLimitTextField.onAmountChange = { [weak self] text in
            guard let self = self, self.isEtherium else { return }
            self.feeIsValid = text.isNotZero == true && self.gasPriceTextField.text?.isNotZero == true
            self.offErrorState()
            self.generator.impactOccurred()
        }
        
        gasPriceTextField.maxDigitsCountAfterSeparator = wallet.currency.decimalDigits
        gasPriceTextField.onAmountChange = { [weak self] text in
            guard let self = self, self.isEtherium else { return }
            self.feeIsValid = self.gasLimitTextField.text?.isNotZero == true && text.isNotZero == true
            self.offErrorState()
            self.generator.impactOccurred()
        }
        
        // send button
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        sendButton.setTitle(NSLocalizedString("BUTTON_CONTINUE", comment: ""), for: .normal)

        // fee text field
        feeTextField.maxDigitsCountAfterSeparator = self.wallet.currency.decimalDigits
        feeTextField.onAmountChange = { [weak self] text in
            guard let self = self else { return }
            self.feeIsValid = text.isNotZero
            self.offErrorState()
            guard let totalValue = self.formatter.multiply(value1: text, value2: self.wallet.currency.rate) else { return }
            self.feeLabel.text = totalValue + " " + self.wallet.currency.rateSymbol
            self.generator.impactOccurred()
        }
    
        feeType = .default
        setupAmountFields()
        addressTextField.delegate = self
    }
    
    func setupTableView() {
        setupKeyboardNotifications()
        view.backgroundColor = Theme.backgroundColor
        view.addSubview(tableViewController.view)
        tableViewController.view.backgroundColor = .clear
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.tableView.contentInset.top = 16
        tableViewController.view.autoPinEdgesToSuperviewSafeArea()
        self.definesPresentationContext = false
        tableViewController.tableView.keyboardDismissMode = .onDrag
        
        tableViewController.view.addSubview(sendButton)
        sendButton.autoPinEdge(.leading, to: .leading, of: tableViewController.view, withOffset: 16)
        sendButton.autoPinEdge(.trailing, to: .trailing, of: tableViewController.view, withOffset: -16)
        sendButton.autoPinEdge(.bottom, to: .bottom, of: tableViewController.view, withOffset: -bottomSpace)
    }
    
    func setupContent() {
        let contents: OWSTableContents = .init()
        let mainSection = OWSTableSection()
        mainSection.add(
            makeItem(parameterTitle: NSLocalizedString("MAIN_WALLET", comment: ""),
                     parameterSubtitle: wallet.currency.name,
                     mainIcon: wallet.currency.icon,
                     value: balance,
                     completion: nil
            )
        )
        
        mainSection.add(
            makeItem(parameterTitle: NSLocalizedString("MAIN_ADDRESS", comment: ""),
                     textField: addressTextField,
                     placeholder: "Please enter address",
                     button: addressButton,
                     icon: #imageLiteral(resourceName: "icon.scanner"),
                     completion: { [weak self] in self?.addressTextField.becomeFirstResponder() }
            )
        )
        addressButton.addTarget(self, action: #selector(addressTap), for: .touchUpInside)
        
        mainSection.add(makeSumItem())
        
        feeButton.addTarget(self, action: #selector(feeTap), for: .touchUpInside)
        
        mainSection.add(
            makeItem(parameterTitle: NSLocalizedString("MAIN_TAG", comment: ""),
                     textField: tagTextField,
                     placeholder: "Please enter tag",
                     value: "Optional",
                     completion: { [weak self] in self?.tagTextField.becomeFirstResponder() }
            )
        )
        
        mainSection.add(
            makeItem(parameterTitle: NSLocalizedString("MAIN_FEE", comment: ""),
                     infoIcon: UIImage(imageLiteralResourceName: "profileMenu.icon.info"),
                     textField: feeTextField,
                     button: feeButton,
                     value: "",
                     icon: #imageLiteral(resourceName: "icon.wallet.fee"),
                     valueTitleLabel: feeLabel,
                     valueSubTitleLabel: feeEquivalentLabel,
                     completion: {}
            )
        )
        if let backgroundView = self.feeTextField.superview?.superview  {
            backgroundView.backgroundColor = feeType == .default ? .clear : Theme.walletBubbleColor
        }
       
        if (isEtherium && feeType == .personal)  {
            //gas price
            mainSection.add(
                makeItem(parameterTitle: "Gas Price (eth)",
                         textField: gasPriceTextField,
                         completion: { [weak self] in self?.gasPriceTextField.becomeFirstResponder() }
                )
            )
            // gas limit
            mainSection.add(
                makeItem(parameterTitle: "Gas Limit",
                         textField: gasLimitTextField,
                         completion: { [weak self] in self?.gasLimitTextField.becomeFirstResponder() }
                )
            )
        }
        
        mainSection.add(makeSendItem())
        
        contents.addSection(mainSection)
        tableViewController.contents = contents
    }
    
    func makeItem(
        parameterTitle: String? = nil,
        parameterSubtitle: String,
        mainIcon: String? = nil,
        value: String? = nil,
        icon: UIImage? = nil,
        completion: (() -> Void)? = nil,
        isEmptyState: Bool = false
    ) -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none

        cell.contentView.layoutMargins.right = cell.contentView.layoutMargins.left
        let parameterTitleLabel = self.parameterTitle(title: parameterTitle)
        
        cell.contentView.addSubview(parameterTitleLabel)
        parameterTitleLabel.autoPinTopToSuperviewMargin()
        parameterTitleLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        
        var imageView = UIImageView()
        if mainIcon != nil {
            imageView = AvatarImageView()
            imageView.sd_setImage(with: URL(string: mainIcon ?? ""), completed: nil)
            imageView.autoSetDimensions(to: CGSize(square: 40))
            imageView.setContentHuggingVerticalLow()
            imageView.setCompressionResistanceVerticalHigh()
            imageView.contentMode = .scaleAspectFit
        }
        
        let parameterSubtitleLabel  = self.parameterSubtitle(subtitle: parameterSubtitle, isEmptyState: isEmptyState)
        
        let valueLabel = self.parameterSubtitle(subtitle: value, isEmptyState: false)
        valueLabel.setContentHuggingHorizontalHigh()
        valueLabel.setCompressionResistanceHorizontalHigh()
        
        let subValue = balance(for: !isRateActive)
        let subValueLabel = self.parameterTitle(title: subValue)
        subValueLabel.setContentHuggingHorizontalHigh()
        subValueLabel.setCompressionResistanceHorizontalHigh()
        
        let balanceStackView = UIStackView(arrangedSubviews: [
            valueLabel,
            subValueLabel
        ])
        balanceStackView.axis = .vertical
        balanceStackView.alignment = .trailing
        balanceStackView.spacing = 4
        
        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        iconView.autoSetDimensions(to: CGSize(square: 24))
        iconView.setContentHuggingHorizontalHigh()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .st_accentGreen
        
        let contentStack = UIStackView(arrangedSubviews: [
            imageView,
            parameterSubtitleLabel,
            balanceStackView,
            iconView
        ])
        contentStack.spacing = 8
        
        cell.contentView.addSubview(contentStack)
        contentStack.autoPinEdge(.top, to: .bottom, of: parameterTitleLabel, withOffset: 4)
        contentStack.autoPinBottomToSuperviewMargin()
        contentStack.autoPinLeadingAndTrailingToSuperviewMargin()
        
        parameterTitleLabel.isHidden = parameterTitle == nil
        iconView.isHidden = icon == nil
        imageView.isHidden = mainIcon == nil
        valueLabel.isHidden = value == nil
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: UITableView.automaticDimension,
                            actionBlock: completion)
    }
    
    func makeItem(
        parameterTitle: String? = nil,
        infoIcon: UIImage? = nil,
        textField: UITextField,
        placeholder: String? = nil,
        button: UIButton? = nil,
        value: String? = nil,
        icon: UIImage? = nil,
        valueTitleLabel: UILabel? = nil,
        valueSubTitleLabel: UILabel? = nil,
        completion: @escaping (() -> Void)
    ) -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        cell.contentView.layoutMargins.right = cell.contentView.layoutMargins.left
        
        let titleStackView = UIStackView()
        cell.contentView.addSubview(titleStackView)
        titleStackView.autoPinTopToSuperviewMargin()
        titleStackView.autoPinLeadingToSuperviewMargin()
        titleStackView.spacing = 8
        
        let parameterTitleLabel = self.parameterTitle(title: parameterTitle)
        parameterTitleLabel.setCompressionResistanceHigh()
        parameterTitleLabel.setContentHuggingHorizontalHigh()
        parameterTitleLabel.setContentHuggingVerticalHigh()
        
        titleStackView.addArrangedSubview(parameterTitleLabel)
        
        if let parameterIcon = infoIcon {
            let parameterImageView = UIImageView(image: parameterIcon)
            parameterImageView.contentMode = .scaleAspectFit
            parameterImageView.backgroundColor = .st_accentGreen
            parameterImageView.widthAnchor.constraint(equalTo: parameterImageView.heightAnchor).isActive = true
            parameterImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            parameterImageView.layer.cornerRadius = 8
            parameterImageView.clipsToBounds = true
            titleStackView.addArrangedSubview(parameterImageView)
            titleStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoButtonTapped)))
        }
        
        if let newButton = button, let newIcon = icon {
            setupButton(button: newButton, icon: newIcon)
        }
        
        let valueLabel: UILabel = valueTitleLabel ?? self.parameterTitle(title: value)
        valueLabel.setContentHuggingHorizontalHigh()
        
        let subValueLabel = valueSubTitleLabel ?? UILabel()
        subValueLabel.setContentHuggingHorizontalHigh()
        subValueLabel.setContentHuggingVerticalHigh()
        
        let valueStackView = UIStackView(arrangedSubviews: [
            valueLabel,
            subValueLabel
        ])
        valueStackView.axis = .vertical
        valueStackView.alignment = .trailing
        valueStackView.spacing = 0
        
        let contentStack = UIStackView(arrangedSubviews: [
            textField,
            valueStackView
        ])
        if placeholder != nil { textField.placeholder = placeholder }
        textField.font = UIFont.st_robotoRegularFont(withSize: 16).ows_semibold
        textField.textColor = Theme.primaryTextColor
        
        contentStack.spacing = 8
        contentStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        let backgroundView = makeBackground()
        cell.contentView.addSubview(backgroundView)
        backgroundView.addSubview(contentStack)
        contentStack.autoPinTopToSuperviewMargin()
        contentStack.autoPinBottomToSuperviewMargin()
        contentStack.autoPinLeadingToSuperviewMargin()

        backgroundView.autoPinEdge(.top, to: .bottom, of: parameterTitleLabel, withOffset: 4)
        backgroundView.autoPinBottomToSuperviewMargin()
        backgroundView.autoPinLeadingToSuperviewMargin()
        
        if let button = button {
            backgroundView.addSubview(button)
            button.autoPinBottomToSuperviewMargin()
            button.autoPinTopToSuperviewMargin()
            button.autoPinTrailingToSuperviewMargin()
            button.autoPinLeading(toTrailingEdgeOf: contentStack, offset: 2)
        } else {
            contentStack.autoPinTrailingToSuperviewMargin()
        }
        
        backgroundView.autoPinTrailingToSuperviewMargin(withInset: 0)
        let tapGesture = TextFieldTapGesture(target: self, action: #selector(setTextFieldFocused(gesture:)))
        tapGesture.textField = textField
        backgroundView.addGestureRecognizer(tapGesture)
        
        valueLabel.isHidden = value == nil
        parameterTitleLabel.isHidden = parameterTitle == nil
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: UITableView.automaticDimension,
                            actionBlock: { completion() })
    }
    
    func makeSumItem() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none

        cell.contentView.layoutMargins.right = cell.contentView.layoutMargins.left

        // символ валюты
        self.amountSymbolLabel = self.parameterTitle(title: wallet.currency.symbol)
        // символ usd
        self.rateAmountSymbolLabel = self.parameterTitle(title: wallet.currency.rateSymbol)
        // заголовок Sum
        let parameterTitleLabel = self.parameterTitle(title: "Amount")
        setupAmountFonts()
        
        cell.contentView.addSubview(parameterTitleLabel)
        parameterTitleLabel.autoPinTopToSuperviewMargin()
        parameterTitleLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        
        changeAmountButton.addTarget(self, action: #selector(updateSumField), for: .touchUpInside)
        setupButton(button: changeAmountButton, icon: #imageLiteral(resourceName: "icon.swap.v"))
        
        clearAmountStack()
        if self.isRateActive {
            amountStack.addArrangedSubview(makeSpecialView(textField: rateAmountTextField, label: rateAmountSymbolLabel))
            amountStack.addArrangedSubview(makeSpecialView(textField: amountTextField, label: amountSymbolLabel))
        } else {
            amountStack.addArrangedSubview(makeSpecialView(textField: amountTextField, label: amountSymbolLabel))
            amountStack.addArrangedSubview(makeSpecialView(textField: rateAmountTextField, label: rateAmountSymbolLabel))
        }
        
        amountStack.axis = .vertical
        amountStack.spacing = 4
        
        let backgroundView = makeBackground()
        cell.contentView.addSubview(backgroundView)
        backgroundView.addSubview(amountStack)
        amountStack.autoPinEdgesToSuperviewMargins()
        
        backgroundView.addSubview(changeAmountButton)
        changeAmountButton.autoPinTopToSuperviewMargin()
        changeAmountButton.autoPinBottomToSuperviewMargin()
        changeAmountButton.autoPinTrailingToSuperviewMargin()
        
        backgroundView.autoPinEdge(.top, to: .bottom, of: parameterTitleLabel, withOffset: 4)
        backgroundView.autoPinBottomToSuperviewMargin()
        backgroundView.autoPinLeadingToSuperviewMargin()
        backgroundView.autoPinTrailingToSuperviewMargin()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setAmountFocused)))
        
        return OWSTableItem(
            customCell: cell,
            customRowHeight: UITableView.automaticDimension,
            actionBlock: { })
    }
    
    func setupButton(button: UIButton, icon: UIImage) {
        button.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
        
        button.tintColor = .st_accentGreen
        button.autoSetDimension(.width, toSize: 40)

        button.contentHorizontalAlignment = .trailing
    }
    
    func makeSendItem() -> OWSTableItem {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none

        cell.contentView.layoutMargins.right = cell.contentView.layoutMargins.left
        cell.contentView.layoutMargins.top = 16
        
        cell.contentView.addSubview(self.errorLabel)
        self.errorLabel.autoPinTopToSuperviewMargin()
        self.errorLabel.autoPinLeadingAndTrailingToSuperviewMargin()
        self.errorLabel.autoPinBottomToSuperviewMargin()
        
        return OWSTableItem(customCell: cell,
                            customRowHeight: 44,
                            actionBlock: nil)
    }
    
    func validation() -> Bool {
        let feePrice = feeType == .default ? feeLabel.text! : feeTextField.text!
        
        if amountTextField.amountForSending()!.doubleValue
            + feePrice.withoutSpaces.withReplacedSeparators.doubleValue
            > wallet.balance.doubleValue {
            errorLabel.text = "Your balance is too low for this transaction"
            return false
        } else if addressTextField.text?.isEmpty != false {
            errorLabel.text = "Enter address"
            return false
        } else if amountTextField.text?.isNotZero != true {
            errorLabel.text = "Enter amount"
            return false
        } else if feeTextField.text?.isNotZero != true && feeType == .personal {
            errorLabel.text = "Fee amount"
            return false
        }

        return true
    }
    
    func handlePrimaryButtonState() {
        sendButton.handleEnabled(addressIsValid && amountIsValid && feeIsValid)
    }
}

// MARK:- Amount
fileprivate extension SendCurrencyFromWalletController {
    
    func clearAmountStack() {
        amountStack.removeAllArrangedSubviews(deactivateConstraints: true)
        
        amountTextField.removeFromSuperview()
        rateAmountTextField.removeFromSuperview()
        amountSymbolLabel.removeFromSuperview()
        rateAmountSymbolLabel.removeFromSuperview()
    }
    
    @objc
    func updateSumField() {
        isRateActive.toggle()
        setupAmountFonts()
        setupContent()
    
        if isRateActive {
            let amountString = amountTextField.text ?? "0"
            let amount = amountString
                .floatFormat(decimalSeparator: amountString.contains(",") ? "," : ".")
                .withReplacedSeparators
                .doubleValue
            rateAmountTextField.setNewValue(usdFormatter.string(from: amount)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        } else {
            amountTextField.setNewValue(rateAmountTextField.text)
        }
        
        self.updateTextFieldSizes()
    }

    func setupAmountFonts() {
        self.amountTextField.font = isRateActive
            ? .st_sfUiTextRegularFont(withSize: 14)
            : (UIFont.st_sfUiTextRegularFont(withSize: 16).ows_semibold)
        
        self.rateAmountTextField.font = !isRateActive
            ? .st_sfUiTextRegularFont(withSize: 14)
            : (UIFont.st_sfUiTextRegularFont(withSize: 16).ows_semibold)
        
        self.amountSymbolLabel.font = isRateActive
            ? UIFont.st_robotoRegularFont(withSize: 12)
            : UIFont.st_robotoRegularFont(withSize: 14)
        
        self.rateAmountSymbolLabel.font = !isRateActive
            ? UIFont.st_robotoRegularFont(withSize: 12)
            : UIFont.st_robotoRegularFont(withSize: 14)
        
        self.amountTextField.isEnabled = !isRateActive
        self.amountTextField.textColor = isRateActive ? Theme.secondaryTextAndIconColor : Theme.primaryTextColor
        self.rateAmountTextField.isEnabled = isRateActive
        self.rateAmountTextField.textColor = isRateActive ? Theme.primaryTextColor : Theme.secondaryTextAndIconColor
        
        self.amountSymbolLabel.textColor = isRateActive ? Theme.secondaryTextAndIconColor : Theme.primaryTextColor
        self.rateAmountSymbolLabel.textColor = isRateActive ? Theme.primaryTextColor : Theme.secondaryTextAndIconColor
    }
    
    func setupAmountFields() {
        // formatter
        formatter.minDecimalDigits = 2
        formatter.decimalDigits = wallet.currency.decimalDigits
        formatter.alwaysShowsDecimalSeparator = true
        
        // amount text field
        amountTextField.setEmptyState()
        amountTextField.maxDigitsCountAfterSeparator = self.wallet.currency.decimalDigits
        amountTextFieldWidthConstraint = amountTextField
            .autoSetDimension(.width, toSize: amountTextField.getSuitableSize())
        amountTextField.onAmountChange  = { [weak self] text in
            guard let self = self else { return }
            self.generator.impactOccurred()
            self.rateAmountTextField.setNewValue(text, multiplier: self.wallet.currency.rate)
            self.amountIsValid = text.isNotZero
            self.updateTextFieldSizes()
            self.offErrorState()
        }
        amountTextField.textColor = Theme.primaryTextColor

        // rate amount text field
        rateAmountTextField.isEnabled = false
        rateAmountTextField.maxDigitsCountAfterSeparator = 2 //self.wallet.currency.decimalDigits
        rateAmountTextFieldWidthConstraint = rateAmountTextField
            .autoSetDimension(.width, toSize: rateAmountTextField.getSuitableSize())
        rateAmountTextField.onAmountChange = { [weak self] text in
            guard let self = self else { return }
            self.generator.impactOccurred()
            self.amountTextField.setNewValue(text, divider: self.wallet.currency.rate)
            self.amountIsValid = text.isNotZero
            self.updateTextFieldSizes()
            self.offErrorState()
        }
        rateAmountTextField.additionalValidation = { [weak self] text in
            guard let self = self,
                let totalValue = self.formatter.divide(value1: text, value2: self.wallet.currency.rate)
                else { return false }
            return self.amountTextField.validText(text: totalValue)
        }
        rateAmountTextField.textColor = Theme.secondaryTextAndIconColor
    }
    
    func updateTextFieldSizes() {
        self.amountTextFieldWidthConstraint.constant = self.amountTextField.getSuitableSize()
        self.rateAmountTextFieldWidthConstraint.constant = self.rateAmountTextField.getSuitableSize()
        self.amountTextField.superview?.layoutIfNeeded()
        self.rateAmountTextField.superview?.layoutIfNeeded()
    }
    
    @objc
    func setAmountFocused() {
        if self.isRateActive {
            self.rateAmountTextField.becomeFirstResponder()
        } else {
            self.amountTextField.becomeFirstResponder()
        }
        offErrorState()
    }
    
    @objc
    func setTextFieldFocused(gesture: TextFieldTapGesture) {
        generator.prepare()
        gesture.textField?.becomeFirstResponder()
    }
    
    @objc
    func infoButtonTapped() {
        let infoController = FeeInfoController()
        infoController.message = feeType.infoMessage
        presentActionSheet(infoController, animated: true)
    }
}

// MARK:- Making Views
fileprivate extension SendCurrencyFromWalletController {
    func makeBackground() -> UIView {
        let backgroundView = UIView()
        backgroundView.layoutMargins = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        backgroundView.backgroundColor = Theme.walletBubbleColor
        backgroundView.layer.cornerRadius = 12
        
        return backgroundView
    }
    
    func makeSpecialView(textField: UITextField, label: UILabel) -> UIView {
        let view = UIView()
        view.layoutMargins = .zero
        view.backgroundColor = .clear
        
        view.addSubview(textField)
        textField.autoPinTopToSuperviewMargin()
        textField.autoPinBottomToSuperviewMargin()
        textField.autoPinLeadingToSuperviewMargin()
        
        view.addSubview(label)
        label.autoPinTopToSuperviewMargin()
        label.autoPinBottomToSuperviewMargin()
        label.autoPinTrailingToSuperviewMargin()
        label.autoPinLeading(toTrailingEdgeOf: textField)
        label.setContentHuggingHorizontalLow()
        
        return view
    }
    
    func parameterTitle(title: String? = nil) -> UILabel {
        let parameterTitleLabel = UILabel()
        parameterTitleLabel.numberOfLines = 0
        parameterTitleLabel.textColor = Theme.secondaryTextAndIconColor
        parameterTitleLabel.font = UIFont.st_robotoRegularFont(withSize: 14)
        parameterTitleLabel.text = title
        return parameterTitleLabel
    }
    
    func parameterSubtitle(subtitle: String?, isEmptyState: Bool) -> UILabel {
        let parameterSubtitleLabel = UILabel()
        parameterSubtitleLabel.textColor = isEmptyState ? Theme.secondaryTextAndIconColor : Theme.primaryTextColor
        parameterSubtitleLabel.font = UIFont.st_robotoRegularFont(withSize: 16).ows_semibold
        parameterSubtitleLabel.text = subtitle
        return parameterSubtitleLabel
    }
}

// MARK:- Actions
fileprivate extension SendCurrencyFromWalletController {
    
    @objc
    func send() {
        hideKeyboard()
        
        guard validation() else { errorLabel.isHidden = false; return }
        errorLabel.isHidden = true
         
        let controller = EnterPasswordBeforeSendingController()
        controller.recieverAddress = self.addressTextField.text!
        controller.onSendTap = { [weak self] password in
            self?.sendRequest(password: password)
        }
        self.presentActionSheet(controller)
        
    }
    
    @objc
    func feeTap() {
        let action = ActionSheetController()
        action.addAction(.init(title: "Personal", style: .default, handler: { [weak self] _ in
            self?.feeType = .personal
        }))
        
        action.addAction(.init(title: "Default", style: .default, handler: { [weak self] _ in
            self?.feeType = .default
        }))
        action.isCancelable = true
        self.presentActionSheet(action)
    }
    
    @objc
    func addressTap() {
        DispatchQueue.main.async {
            let controller = ScanQRController()
            controller.returnScreen = self
            controller.result = { [weak self] address in
                self?.addressTextField.text = address
                self?.addressIsValid = !address.isEmpty
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func offErrorState() {
        errorLabel.isHidden = true
    }
}

// MARK:- Requests
fileprivate extension SendCurrencyFromWalletController {
    func sendRequest(password: String) {
        guard let amount = self.amountTextField.amountForSending() else { return }
        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: false,
            backgroundBlock: { [weak self] modal in
                guard let self = self else { return }
                WalletModel.shared.sendCurrency(
                    wallet: self.wallet,
                    password: password,
                    destinationAddress: self.addressTextField.text!,
                    amount: amount,
                    fee: self.feeType == .default ? nil : self.feeTextField.amountForSending(),
                    customGasPrice: self.gasPriceTextField.amountForSending(),
                    customGasLimit: self.gasLimitTextField.amountForSending()?.integerValue,
                    completion: { result in
                        switch result {
                        case .success(_):
                            let currencyAmountPart = amount + " " + self.wallet.currency.symbol
                            let rateAmountPart = self.rateAmountTextField.text! + " " + self.wallet.currency.rateSymbol
                            modal.dismiss {
                                let controller = SentSucceedCurrencyController()
                                controller.sentMoneyInfo = currencyAmountPart + " = " + rateAmountPart
                                controller.fromViewController = self
                                self.presentActionSheet(controller)
                            }
                            
                            break
                        case .failure(let error):
                            if error.isNetworkFailureOrTimeout {
                                modal.dismiss {
                                    OWSActionSheets.showErrorAlert(message: error.localizedDescription)
                                }
                            } else {
                                modal.dismiss {
                                    self.errorLabel.text = error.localizedDescription
                                    self.errorLabel.isHidden = false
                                }
                            }
                            
                            AnalyticsService.log(event: .moneySendFailure, parameters: nil)
                        }
                })
        })
    }
}

// MARK:- Notification
fileprivate extension SendCurrencyFromWalletController {
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        
        if isKeyboardShowing {
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height + 16, right: 0.0)
            tableViewController.tableView.contentInset = insets
            tableViewController.tableView.scrollIndicatorInsets = insets
            
            var mainRect = self.view.frame
            mainRect.size.height -= keyboardFrame.height
            
            guard let activeTextField = textFields.filter({ $0.isFirstResponder == true }).first else { return }
            if mainRect.contains(activeTextField.frame.origin) {
                tableViewController.tableView.scrollRectToVisible(activeTextField.frame, animated: true)
            }
        } else {
            let insents = UIEdgeInsets.zero
            tableViewController.tableView.contentInset = insents
            tableViewController.tableView.scrollIndicatorInsets = insents
        }
    }
    
    @objc func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        tableViewController.tableView.backgroundColor = Theme.backgroundColor
        tableViewController.tableView.backgroundView?.backgroundColor = Theme.backgroundColor
        setupContent()
    }
}


class TextFieldTapGesture: UITapGestureRecognizer {
    weak var textField: UITextField?
}
