//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class CancelPinController: ActionSheetController {
    typealias FinishHandler = (Bool) -> Void
    public var finish: FinishHandler?
    
    public var customTitle: String = "Cancel pin of wallet"
    
    private let attemptsAlertThreshold = 4
    
    private let pinTextField: UITextField = {
        let pinTextField = UITextField()
        pinTextField.isSecureTextEntry = true
        pinTextField.textColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
        pinTextField.textAlignment = .center
        pinTextField.font = .wlt_dynamicTypeBodyClamped
        pinTextField.isSecureTextEntry = true
        pinTextField.defaultTextAttributes.updateValue(5, forKey: .kern)
//        pinTextField.keyboardAppearance = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.keyboardAppearance
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
    private lazy var pinStrokeNormal = pinTextField.addBottomStroke()
    private lazy var pinStrokeError = pinTextField.addBottomStroke(color: .wlt_accentRed, strokeWidth: 2)
    private let validationWarningLabel: UILabel = {
        let validationWarningLabel = UILabel()
        validationWarningLabel.textColor = .wlt_otherRed
        validationWarningLabel.textAlignment = .center
        validationWarningLabel.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        validationWarningLabel.numberOfLines = 0
        return validationWarningLabel
    }()

    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Enter the PIN to continue"
        label.font = UIFont.systemFont(ofSize: 14) // MARK: - SINGAL DEPENDENCY - FONT  = UIFont.stwlt._sfUiTextRegularFont(withSize: 14)
        label.textColor = .wlt_neutralGray
        return label
    }()
    
    enum PinAttemptState {
        case unattempted
        case invalid(remainingAttempts: UInt32?)
        case exhausted
        case valid
        
        var isInvalid: Bool {
            switch self {
            case .unattempted, .valid:
                return false
            case .invalid, .exhausted:
                return true
            }
        }
    }
    private var attemptState: PinAttemptState = .unattempted {
        didSet {
            updateValidationWarnings()
        }
    }
    
//    private var pinType: KeyBackupService.PinType = .numeric

    private var topPadding: CGFloat = 0.0
    //TODO: Replace with DI
    private let credentialsManager: CredentialsManager = DefaultCredentialsManager(storage: KeychainCredentialsStorageService())

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
        
        _ = pinTextField.becomeFirstResponder()
    }
}

extension CancelPinController: UITextFieldDelegate {
    func setupContent() {
        pinTextField.delegate = self
        pinTextField.wltSetContentHuggingHorizontalLow()
        pinTextField.wltSetCompressionResistanceHorizontalLow()
        pinTextField.autoSetDimension(.height, toSize: 40)
        
        validationWarningLabel.wltSetCompressionResistanceHigh()
        
        let pinStack = UIStackView(arrangedSubviews: [
            pinTextField,
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
            explanationLabel,
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
        
        explanationLabel.autoMatch(.width, to: .width, of: view, withOffset: -32)
        handlePrimaryButtonState(!(pinTextField.text?.isEmpty == true))
        
        // Because of the keyboard, vertical spacing can get pretty cramped,
        // so we have custom spacer logic.
        stackView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        autoPinView(toBottomOfViewControllerOrKeyboard: stackView, avoidNotch: true)
        
        // Ensure whitespace is balanced, so inputs are vertically centered.
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)
        
        updateValidationWarnings()
    }
    
    private func updateValidationWarnings() {
        pinStrokeNormal.isHidden = attemptState.isInvalid
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        handlePrimaryButtonState(!newString.isEmpty)
       
        if newString.count > 6 { return false }
        
        let hasPendingChanges: Bool
        // MARK: - SINGAL DEPENDENCY – reimplement
//        if pinType == .numeric {
//            ViewControllerUtils.ows2FAPINTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
//            hasPendingChanges = false
//        } else {
            hasPendingChanges = true
//        }

        // Reset the attempt state to clear errors, since the user is trying again
        attemptState = .unattempted

        return hasPendingChanges
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tryToVerify()
        return false
    }

    private func tryToVerify() {
        if wallet.credentials?.pin == pinTextField.text {
            close()
            finish?(true)
        }
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
                    guard let self = self else { return }
                    self.credentialsManager.resetCredential(ofType: .pin, forWalletWithId: self.walletId) { (_) in
                        // handle error
                        modal.dismiss { }
                        self.close()
                    }
                }
        })
    }
    
    func validation() -> Bool {
        var hasError: Bool = false
        if pinTextField.text?.isEmpty != false {
            validationWarningLabel.text = NSLocalizedString("WALLET_ENTER_PIN", comment: "")
            hasError = true
        }
        
        validationWarningLabel.isHidden = !hasError
        
        return !hasError
    }
    
    @objc
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func handlePrimaryButtonState(_ isFilled: Bool) {
        primaryButton.handleEnabled(isFilled)
    }
    
    @objc
    func close() {
        hideKeyboard()
        self.dismiss(animated: true, completion:  nil)
    }
}
