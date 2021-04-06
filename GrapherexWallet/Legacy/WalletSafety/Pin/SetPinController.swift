//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class SetPinController: ActionSheetController {
    typealias FinishHandler = (Bool) -> Void
    public var finish: FinishHandler?
    
    public var customTitle: String = "Set pin of wallet"
    
    private var newPinIsValid: Bool = false {
        didSet {
            handlePrimaryButtonState()
        }
    }
    
    private var confirmPinIsValid: Bool = false {
        didSet {
            handlePrimaryButtonState()
        }
    }
    
    private let newPinTextField: UITextField = {
        let pinTextField = UITextField()
        pinTextField.placeholder = "New"
        pinTextField.textAlignment = .center
        pinTextField.isSecureTextEntry = true
        pinTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        pinTextField.font = .wlt_dynamicTypeBodyClamped
//        pinTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
        pinTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        pinTextField.keyboardType = .decimalPad
        return pinTextField
    }()

    private let confirmPinTextField: UITextField = {
        let pinTextField = UITextField()
        pinTextField.placeholder = "Confirm"
        pinTextField.textAlignment = .center
        pinTextField.isSecureTextEntry = true
        pinTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        pinTextField.font = .wlt_dynamicTypeBodyClamped
//        pinTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
        pinTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
        pinTextField.keyboardType = .decimalPad
        return pinTextField
    }()
    
    private let primaryButton: STPrimaryButton = {
        let button = STPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let buttonContainer = UIView()
    private lazy var newPinStrokeNormal = newPinTextField.addBottomStroke()
    private lazy var confirmPinStrokeNormal = confirmPinTextField.addBottomStroke()
    
    private lazy var newPinStrokeError = newPinTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    private lazy var confirmPinStrokeError = confirmPinTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    
    private let validationWarningLabel: UILabel = {
        let validationWarningLabel = UILabel()
        validationWarningLabel.textColor = .stwlt_otherRed
        validationWarningLabel.textAlignment = .center
        validationWarningLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        validationWarningLabel.numberOfLines = 0
        return validationWarningLabel
    }()
    
    enum PinAttemptState {
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
    
    private var attemptState: PinAttemptState = .valid {
        didSet {
            updateValidationWarnings()
        }
    }
    
//    private var pinType: KeyBackupService.PinType = .numeric

    private var topPadding: CGFloat = 0.0

    public var walletId: String! {
        didSet {
            wallet = WalletModel.shared.getWalletById(id: walletId)
        }
    }
    
    public var wallet: Wallet!
    
    override func setup() {
        super.setup()
        stackView.spacing = 4
        setupMargins(margin: 16)
        
        isCancelable = true
        setupCenterHeader(
            title: customTitle,
            close: #selector(close))
        
        let window = UIApplication.shared.keyWindow
        topPadding = window?.safeAreaInsets.top ?? 0
        scrollView.bounces = false
        scrollView.autoPinEdge(.top, to: .top, of: view, withOffset: topSpace + topPadding)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nothing)))
        setupContent()
    }
    
    @objc func nothing() {}
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = newPinTextField.becomeFirstResponder()
    }
}

extension SetPinController: UITextFieldDelegate {
    func setupContent() {
        newPinTextField.delegate = self
        newPinTextField.wltSetContentHuggingHorizontalLow()
        newPinTextField.wltSetCompressionResistanceHorizontalLow()
        newPinTextField.autoSetDimension(.height, toSize: 40)
        
        confirmPinTextField.delegate = self
        confirmPinTextField.wltSetContentHuggingHorizontalLow()
        confirmPinTextField.wltSetCompressionResistanceHorizontalLow()
        confirmPinTextField.autoSetDimension(.height, toSize: 40)
        
        validationWarningLabel.wltSetCompressionResistanceHigh()
        
        let pinStack = UIStackView(arrangedSubviews: [
            newPinTextField,
            UIView.spacer(withHeight: 10),
            confirmPinTextField,
            UIView.spacer(withHeight: 10),
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
        
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
       
        let arrangedSubviews =  [
            UIView.spacer(withHeight: 10),
            topSpacer,
            pinStackRow,
            bottomSpacer,
            UIView.spacer(withHeight: 10),
            buttonContainer
        ]
        stackView.axis = .vertical
        stackView.alignment = .fill
        
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
    
    private func updateValidationWarnings() {
        newPinStrokeNormal.isHidden = attemptState.isInvalid
        confirmPinStrokeNormal.isHidden = attemptState.isInvalid
        
        newPinStrokeError.isHidden = !attemptState.isInvalid
        confirmPinStrokeError.isHidden = !attemptState.isInvalid
        
        validationWarningLabel.isHidden = !attemptState.isInvalid
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        
        if newString.count > 6 { return false }
        
        if textField === newPinTextField {
            newPinIsValid = !newString.isEmpty
        } else if textField === confirmPinTextField {
            confirmPinIsValid = !newString.isEmpty
        }
        attemptState = .valid
        // MARK: - SINGAL DEPENDENCY – reimplement
//        ViewControllerUtils.ows2FAPINTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
        
        return false
    }
    
    @objc
    func enterButtonPressed() {
        hideKeyboard()
        
        guard validation() else { return }
        
        ModalActivityIndicatorViewController.present(
            fromViewController: self,
            canCancel: false,
            backgroundBlock: { [weak self] modal in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let self = self,
                        let text = self.newPinTextField.text else { return }
                    
                    if !WalletCredentialsManager.update(credentialType: .pin, newValue: text, walletId: self.walletId) {
                        self.validationWarningLabel.isHidden = false
                        self.validationWarningLabel.text = "Something went wrong. Try later"
                        modal.dismiss { }
                    } else {
                        modal.dismiss { }
                        self.close()
                    }
                }
        })
    }
    
    func validation() -> Bool {
        var hasError: Bool = false
        
        if (newPinTextField.text != confirmPinTextField.text
            || newPinTextField.text?.isEmpty != false
            || confirmPinTextField.text?.isEmpty != false) {
            validationWarningLabel.text = newPinTextField.text != confirmPinTextField.text
                ? NSLocalizedString("WALLET_PINS_DO_NOT_MATCH", comment: "")
                : NSLocalizedString("WALLET_ENTER_PIN", comment: "")
            hasError = true
            attemptState = .invalid
        } else if newPinTextField.text?.count ?? 0 > 6 || confirmPinTextField.text?.count ?? 0 > 6 {
            validationWarningLabel.text = NSLocalizedString("WALLET_ERROR_TOO_LONG", comment: "")
            hasError = true
            attemptState = .invalid
        } else {
            attemptState = .valid
        }
        
        return !hasError
    }
    
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func handlePrimaryButtonState() {
        let isFilled = newPinIsValid && confirmPinIsValid
        primaryButton.handleEnabled(isFilled)
    }
    
    @objc
    func close() {
        hideKeyboard()
        self.dismiss(animated: true, completion:  nil)
    }
}
