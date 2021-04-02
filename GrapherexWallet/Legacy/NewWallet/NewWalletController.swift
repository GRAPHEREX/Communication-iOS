//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final public class NewWalletController: ActionSheetController {
    
    private let passwordLenght: Int = WalletModel.passwordLenght
    private let doneButton = STPrimaryButton()
    
    private var currencyTitleLabel: UILabel!
    private var newTitleLabel: UILabel!
    private var confirmTitleLabel: UILabel!
    private let infoLabel = UILabel()
    private let errorLabel =  UILabel()
    private var currencyStack = UIStackView()
    
    private var currencyTextField: UITextField!
    private var newTextField: UITextField! { didSet {
        newTextField.disableAutoFill()
    }}
    private var confirmTextField: UITextField! { didSet {
        confirmTextField.disableAutoFill()
    }}

    private let currencyImageView = UIImageView()
    
    private var currencyIsValid: Bool = false { didSet {
        handlePrimaryButtonState()
    }}
    
    private var passwordIsValid: Bool = false { didSet {
        handlePrimaryButtonState()
    }}
    
    private var confirmIsValid: Bool = false { didSet {
        handlePrimaryButtonState()
    }}
    
    // MARK: - Dependencies
    private var walletModel: WalletModel {
        return WalletModel.shared
    }
    
    public override func setup() {
        super.setup()
        stackView.spacing = 12
        setupMargins(margin: 16)
        
        isCancelable = true
        currencyImageView.autoSetDimensions(to: .init(width: 32, height: 32))
        currencyImageView.contentMode = .scaleAspectFit
        setupCenterHeader(title: NSLocalizedString("WALLET_NEW_WALLET_TITLE", comment: ""), close: #selector(close))
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.bounces = false
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        setupContent()
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
}

extension NewWalletController: UITextFieldDelegate {
    
    private func setupContent() {
        makeSelectCurrencyField()
        makeNewPasswordField()
        makeConfirmPasswordField()
        doneButton.handleEnabled(false)
        
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.textColor = Theme.secondaryTextAndIconColor
        infoLabel.text = NSLocalizedString("WALLET_NEW_WALLET_VALIDATION_INFO", comment: "")
        infoLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        
        errorLabel.textAlignment = .center
        errorLabel.textColor = .st_otherRed
        errorLabel.isHidden = true
        errorLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14).ows_semibold
        
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(UIView.hStretchingSpacer())
        
        setupButton()
    }

    private func makeSelectCurrencyField() {
        currencyTitleLabel = self.title(titleText: NSLocalizedString("MAIN_CURRENCY", comment: ""))
        currencyTextField = self.textField(textField: UITextField(), placeholder: "Choose currency")
        currencyTextField.isEnabled = false
        
        currencyStack = UIStackView(arrangedSubviews: [
            currencyTitleLabel,
            currencyImageView,
            currencyTextField
        ])
        
        currencyImageView.setContentHuggingHorizontalHigh()
        currencyImageView.isHidden = true
        self.stackView.addArrangedSubview(currencyStack)
        currencyStack.autoSetDimension(.height, toSize: 40)

        currencyStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRecipientPicker)))
    }
    
    private func makeNewPasswordField() {
        newTitleLabel = self.title(titleText: NSLocalizedString("MAIN_NEW", comment: ""))
        newTextField = self.textField(textField: SecureTextField(), placeholder: NSLocalizedString("MAIN_PASSWORD", comment: ""))
        makeView(titleLabel: newTitleLabel, textField: newTextField)
    }
    
    private func makeConfirmPasswordField() {
        confirmTitleLabel = self.title(titleText: NSLocalizedString("MAIN_CONFIRM", comment: ""))
        confirmTextField = self.textField(textField: SecureTextField(), placeholder: NSLocalizedString("MAIN_PASSWORD", comment: ""))
        makeView(titleLabel: confirmTitleLabel, textField: confirmTextField)
    }
    
    private func makeView(titleLabel: UILabel, textField: UITextField) {
        let backgroundView = UIView()
        backgroundView.addSubview(textField)

        textField.autoPinLeading(toEdgeOf: backgroundView, offset: 8)
        textField.autoPinTrailing(toEdgeOf: backgroundView, offset: -8)
        textField.autoPinEdge(.top, to: .top, of: backgroundView, withOffset: 8)
        textField.autoPinEdge(.bottom, to: .bottom, of: backgroundView, withOffset: -8)
        backgroundView.autoSetDimension(.height, toSize: 36)

        backgroundView.backgroundColor = Theme.walletBubbleColor
        backgroundView.layer.cornerRadius = 12
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            backgroundView
        ])
        self.stackView.addArrangedSubview(stack)
    }
    
    private func title(titleText: String) -> UILabel {
        let titleLabel = UILabel()
        
        titleLabel.autoSetDimension(.width, toSize: 72)
        titleLabel.text = titleText
        titleLabel.textColor = Theme.primaryTextColor
        titleLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 14).ows_semibold
        
        return titleLabel
    }
    
    private func textField(textField: UITextField, placeholder: String) -> UITextField {
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.textColor = Theme.primaryTextColor
        textField.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        textField.placeholder = placeholder
        
        return textField
    }
    
    private func setupButton() {
        view.addSubview(doneButton)
        doneButton.autoPinEdge(.leading, to: .leading, of: view, withOffset: 16)
        doneButton.autoPinEdge(.trailing, to: .trailing, of: view, withOffset: -16)
        doneButton.setTitle(NSLocalizedString("MAIN_DONE", comment: ""), for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
             
        autoPinView(toBottomOfViewControllerOrKeyboard: doneButton, avoidNotch: true, withInset: 8, saveInset: true)
    }
    
    @objc private
    func doneButtonPressed() {
        hideKeyboard()
        
        guard validation() else { return }
        
        guard
            let currencyTitle = currencyTextField.text,
            let currency = walletModel.currencies.first(where: { $0.name.lowercased() == currencyTitle.lowercased() }),
            let password = newTextField.text
        else {
            return
        }
        
        ModalActivityIndicatorViewController.present (
            fromViewController: self,
            canCancel: false,
            backgroundBlock: { [weak self] modal in
                self?.walletModel.createWallet(currency, password: password) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        NotificationCenter.default.post(
                            name: WalletModel.walletsNeedUpdate,
                            object: nil
                        )
                        modal.dismiss {
                            let controller = NewWalletSuccessController()
                            controller.password = password
                            controller.fromViewController = self
                            self.presentActionSheet(controller)
                        }
                    case .failure(let error):
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = error.localizedDescription
                        modal.dismiss {}
                    }
                }
        })
    }
    
    private func isValidPassword(password: String) -> Bool {
        return walletModel.isValidPassword(password: password)
    }
    
    private func validation() -> Bool {
        errorLabel.text = ""
        
        if (newTextField.text != confirmTextField.text) {
            newTitleLabel.textColor = .st_otherRed
            confirmTitleLabel.textColor = .st_otherRed
            errorLabel.text = "Passwords do not match"
        } else if !isValidPassword(password: newTextField.text!) {
            newTitleLabel.textColor = .st_otherRed
            confirmTitleLabel.textColor = .st_otherRed
            self.infoLabel.textColor = .st_otherRed
            return false
        } else {
            newTitleLabel.textColor = Theme.primaryTextColor
            confirmTitleLabel.textColor = Theme.primaryTextColor
        }
        
        if currencyTextField.text?.isEmpty != false {
            currencyTitleLabel.textColor = .st_otherRed
            errorLabel.text = "Choose currency"
        } else {
            currencyTitleLabel.textColor = Theme.primaryTextColor
        }
        
        let isValid = errorLabel.text?.isEmpty == true
        errorLabel.isHidden = isValid
        
        return isValid
    }
    
    @objc private
    func textFieldDidChange(sender: UITextField) {
        if sender === currencyTextField {
            currencyIsValid = currencyTextField.text?.isEmpty != true
            currencyTitleLabel.textColor = Theme.primaryTextColor
        } else if sender === newTextField || sender === confirmTextField {
            newTitleLabel.textColor = Theme.primaryTextColor
            confirmTitleLabel.textColor = Theme.primaryTextColor
            passwordIsValid = newTextField.text?.isEmpty == false
            confirmIsValid = confirmTextField.text?.isEmpty == false
            infoLabel.textColor = Theme.secondaryTextAndIconColor
        }
    }
    
    @objc private
    func showRecipientPicker() {
        let controller = CurrencyPickerController()
        controller.finish = { [weak self] currency in
            self?.currencyStack.spacing = 4
            self?.currencyImageView.isHidden = false
            self?.currencyImageView.sd_setImage(with: URL(string: currency.icon), completed: nil)
            self?.currencyTextField.text = currency.name
            self?.currencyIsValid = true
        }
        
        self.presentActionSheet(controller, completion: { } )
    }
    
    func handlePrimaryButtonState() {
        doneButton.handleEnabled(currencyIsValid && passwordIsValid && confirmIsValid)
    }
    
    @objc private
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private 
    func close() {
        hideKeyboard()
        self.dismiss(animated: true, completion:  nil)
    }
}
