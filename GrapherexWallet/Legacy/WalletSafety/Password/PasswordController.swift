//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class PasswordController: ActionSheetController {
    typealias CompletionHandler = () -> Void
    public var completion: CompletionHandler?
    
    enum Constants {
        static let margin: CGFloat = 16.0
    }
    
    private let passwordLenght: Int = WalletModel.passwordLenght
    private var currentPasswordIsValid: Bool = false {
        didSet {
            handlePrimaryButtonState()
        }
    }
    
    private var newPasswordIsValid: Bool = false {
        didSet {
            handlePrimaryButtonState()
        }
    }
    
    private var confirmPasswordIsValid: Bool = false {
        didSet {
            handlePrimaryButtonState()
        }
    }
    
    private var walletModel: WalletModel {
        return WalletModel.shared
    }
    
    private var isShortDevice: Bool {
        return UIDevice.current.isIPhone5OrShorter
    }
    
    private var passwordSpacerHeight: CGFloat {
        return UIDevice.current.isIPhone5OrShorter ? 4.0 : 8.0
    }
    
    private let currentPasswordTextField: SecureTextField = {
        let passwordTextField = SecureTextField()
        passwordTextField.placeholder = "Current"
        passwordTextField.textAlignment = .center
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        passwordTextField.font = .wlt_dynamicTypeBodyClamped
//        passwordTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
        passwordTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        return passwordTextField
    }()
    
    private let newPasswordTextField: SecureTextField = {
        let passwordTextField = SecureTextField()
        passwordTextField.placeholder = "New"
        passwordTextField.textAlignment = .center
        passwordTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        passwordTextField.font = .wlt_dynamicTypeBodyClamped
//        passwordTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
        passwordTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        return passwordTextField
    }()
    
    private let confirmPasswordTextField: SecureTextField = {
        let passwordTextField = SecureTextField()
        passwordTextField.placeholder = "Confirm"
        passwordTextField.textAlignment = .center
        passwordTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        passwordTextField.font = .wlt_dynamicTypeBodyClamped
//        passwordTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
        passwordTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        return passwordTextField
    }()
    
    private let primaryButton: STPrimaryButton = {
        let button = STPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.secondaryTextAndIconColor
        label.text = "The password must contain numbers, uppercase and lowercase letters and contain at least 8 characters";
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        return label
    }()
    
    private let buttonContainer = UIView()
    private lazy var currentPasswordStrokeNormal = currentPasswordTextField.addBottomStroke()
    private lazy var newPasswordStrokeNormal = newPasswordTextField.addBottomStroke()
    private lazy var confirmPasswordStrokeNormal = confirmPasswordTextField.addBottomStroke()
    
    private lazy var currentPasswordStrokeError = currentPasswordTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    private lazy var newPasswordStrokeError = newPasswordTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    private lazy var confirmPasswordStrokeError = confirmPasswordTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    
    private let validationWarningLabel: UILabel = {
        let validationWarningLabel = UILabel()
        validationWarningLabel.textColor = .stwlt_otherRed
        validationWarningLabel.textAlignment = .center
        validationWarningLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        validationWarningLabel.numberOfLines = 0
        return validationWarningLabel
    }()
    
    enum PasswordAttemptState {
        case invalid
        case valid
        
        var isInvalid: Bool {
            switch self {
            case .valid:
                return false
            case .invalid:
                return true
            }
        }
    }
    
    private var attemptState: PasswordAttemptState = .valid {
        didSet {
            updateValidationWarnings()
        }
    }
    
    enum Mode {
        case enterPassword
        case setFirstPassword
        case changePassword
        
        var title: String {
            switch self {
            case .enterPassword:
                return "Enter password"
            case .setFirstPassword:
                return "Set password"
            case .changePassword:
                return "Set new password"
            }
        }
    }
    
    public var mode: Mode = .enterPassword {
        didSet {
            switch mode {
            case .enterPassword:
                newPasswordTextField.isHidden = true
                confirmPasswordTextField.isHidden = true
            case .setFirstPassword:
                currentPasswordTextField.isHidden = true
            case .changePassword:
                break
            }
        }
    }
    
//    private var passwordType: KeyBackupService.PinType = .alphanumeric
    
    private var topPadding: CGFloat = 0.0
    
    var walletId: String! { didSet {
        self.wallet = walletModel.getWalletById(id: walletId)
    }}
    
    private(set) var wallet: Wallet!
    
    override func setup() {
        super.setup()
        stackView.spacing = 4
        setupMargins(margin: Constants.margin)
        infoLabel.autoSetDimension(.width, toSize: UIScreen.main.bounds.size.width - 2*Constants.margin)
        
        isCancelable = true
        setupCenterHeader(
            title: mode.title,
            close: #selector(close))
        
        NSLayoutConstraint.activate([
            customHeader!.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let window = UIApplication.shared.keyWindow
        topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.bounces = false
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
        setupContent()
        setupKeyboardNotifications()
    }

    @objc func nothing() {}

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch mode {
        case .setFirstPassword:
             _ = newPasswordTextField.becomeFirstResponder()
        case .enterPassword, .changePassword:
            _ = currentPasswordTextField.becomeFirstResponder()
        }
    }
    
    public func setCurrentPassword(password: String) {
        currentPasswordTextField.text = password
        currentPasswordIsValid = !password.isEmpty
    }
    
    private func setupKeyboardNotifications() {
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
        infoLabel.isHidden = (notification.name == UIResponder.keyboardWillShowNotification) && isShortDevice
    }
}

extension PasswordController: UITextFieldDelegate {
    private func isValidPassword(_ password: String) -> Bool {
        return walletModel.isValidPassword(password: password)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        
        if textField === newPasswordTextField {
            newPasswordIsValid = !newString.isEmpty
        } else if textField === confirmPasswordTextField {
            confirmPasswordIsValid = !newString.isEmpty
        } else if textField === currentPasswordTextField {
            currentPasswordIsValid = !newString.isEmpty
        }
        attemptState = .valid
        
        //        ViewControllerUtils.ows2FAPINTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
        
        return true
    }
    
}

fileprivate extension PasswordController {
    
    func setupContent() {
        currentPasswordTextField.delegate = self
        currentPasswordTextField.wltSetContentHuggingHorizontalLow()
        currentPasswordTextField.wltSetCompressionResistanceHorizontalLow()
        currentPasswordTextField.autoSetDimension(.height, toSize: 40)
        
        newPasswordTextField.delegate = self
        newPasswordTextField.wltSetContentHuggingHorizontalLow()
        newPasswordTextField.wltSetCompressionResistanceHorizontalLow()
        newPasswordTextField.autoSetDimension(.height, toSize: 40)
        
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.wltSetContentHuggingHorizontalLow()
        confirmPasswordTextField.wltSetCompressionResistanceHorizontalLow()
        confirmPasswordTextField.autoSetDimension(.height, toSize: 40)
        
        validationWarningLabel.wltSetCompressionResistanceHigh()
        
        let pinStack = UIStackView(arrangedSubviews: [
            currentPasswordTextField,
            UIView.spacer(withHeight: passwordSpacerHeight),
            newPasswordTextField,
            UIView.spacer(withHeight: passwordSpacerHeight),
            confirmPasswordTextField,
            UIView.spacer(withHeight: passwordSpacerHeight),
            validationWarningLabel
        ])
        pinStack.axis = .vertical
        pinStack.alignment = .fill
        
        let pinStackRow = UIView()
        pinStackRow.addSubview(pinStack)
        pinStack.wltAutoHCenterInSuperview()
        pinStack.wltAutoPinHeightToSuperview()
        pinStack.autoSetDimension(.width, toSize: 227)
        pinStackRow.wltSetContentHuggingVerticalHigh()
        
        buttonContainer.addSubview(primaryButton)
        primaryButton.autoPinEdgesToSuperviewEdges(with: .init(top: 0, left: 16, bottom: 0, right: 16))
        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        
        let arrangedSubviews =  [
            UIView.spacer(withHeight: 10),
            topSpacer,
            pinStackRow,
            infoLabel,
            bottomSpacer,
            UIView.spacer(withHeight: 10),
            buttonContainer
        ]
        stackView.axis = .vertical
        stackView.alignment = .fill
        
        if mode == .enterPassword { infoLabel.isHidden = true }
        arrangedSubviews.forEach {
            stackView.addArrangedSubview($0)
        }
        
        handlePrimaryButtonState()
        
        // Because of the keyboard, vertical spacing can get pretty cramped,
        // so we have custom spacer logic.
        stackView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        autoPinView(toBottomOfViewControllerOrKeyboard: stackView, avoidNotch: true)
        
        // Ensure whitespace is balanced, so inputs are vertically centered.
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
        
        updateValidationWarnings()
    }
    
    func updateValidationWarnings() {
        switch mode {
        case .enterPassword:
            break
        case .setFirstPassword:
            confirmPasswordStrokeNormal.isHidden = attemptState.isInvalid
            confirmPasswordStrokeError.isHidden = !attemptState.isInvalid

        case .changePassword:
            confirmPasswordStrokeNormal.isHidden = attemptState.isInvalid
            confirmPasswordStrokeError.isHidden = !attemptState.isInvalid
            
            currentPasswordStrokeNormal.isHidden = attemptState.isInvalid
            currentPasswordStrokeError.isHidden = !attemptState.isInvalid
        }
        
        newPasswordStrokeNormal.isHidden = attemptState.isInvalid
        newPasswordStrokeError.isHidden = !attemptState.isInvalid
        
        validationWarningLabel.isHidden = !attemptState.isInvalid
        infoLabel.textColor = attemptState.isInvalid
            ? .stwlt_otherRed
            : .stwlt_otherRed//Theme.secondaryTextAndIconColor
    }
    
    func isValid() -> Bool {
        switch mode {
        case .enterPassword:
            return currentPasswordIsValid
        case .setFirstPassword:
             return newPasswordIsValid && confirmPasswordIsValid
        case .changePassword:
            return currentPasswordIsValid && newPasswordIsValid && confirmPasswordIsValid
        }
    }
    
    func enterPassword() {
        print(#function)
    }
    
    func setFirstPassword() {
        //Logger.info("Try to set new Password")
        guard let password = newPasswordTextField.text else { return }
        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: false,
            backgroundBlock: { [weak self] modal in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    guard let self = self else { return }
                    self.walletModel.setFirstPassword(for: self.wallet, password: password) { result in
                        switch result {
                        case .success:
                            modal.dismiss {
                                self.next()
                            }
                        case .failure(let error):
                            modal.dismiss {
                                self.validationWarningLabel.text = error.localizedDescription
                                self.validationWarningLabel.isHidden = false
                            }
                        }
                    }
                }
        })
    }
    
    func changePassword() {
        //Logger.info("Try to change Password")
        guard let password = newPasswordTextField.text,
            let oldPassword = currentPasswordTextField.text else { return }

        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: false,
            backgroundBlock: { [weak self] modal in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    guard let self = self else { return }
                    self.walletModel.changePassword(wallet: self.wallet, oldPassword: oldPassword, newPassword: password) { result in
                        switch result {
                        case .success:
                            modal.dismiss {
                                self.next()
                            }
                        case .failure(let error):
                            modal.dismiss {
                                self.validationWarningLabel.text = error.localizedDescription
                                self.validationWarningLabel.isHidden = false
                            }
                        }
                    }
                }
        })
    }
    
    func next() {
        let controller = QRPasswordSaveController()
        controller.password = newPasswordTextField.text!
        controller.fromViewController = self
        controller.completion = completion
        self.presentActionSheet(controller)
    }
    
    @objc
    func enterButtonPressed() {
        hideKeyboard()
        
        guard validation() else { return }
        
        switch mode {
        case .enterPassword:
            enterPassword()
        case .setFirstPassword:
            setFirstPassword()
        case .changePassword:
            changePassword()
        }
    }
    
    func validation() -> Bool {
        guard isValid() else { return false }

        switch mode {
        case .enterPassword:
            break
        case .setFirstPassword, .changePassword:
            if (newPasswordTextField.text != confirmPasswordTextField.text) {
                validationWarningLabel.text =  "Password do not match"
                attemptState = .invalid
                return false
            } else if !isValidPassword(newPasswordTextField.text!) {
                infoLabel.textColor = .stwlt_otherRed
                attemptState = .invalid
                return false
            }
        }
        
        attemptState = .valid
        return true
    }
    
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func handlePrimaryButtonState() {
        primaryButton.handleEnabled(isValid())
    }
    
    @objc
    func close() {
        hideKeyboard()
        self.dismiss(animated: true, completion:  nil)
    }
}
