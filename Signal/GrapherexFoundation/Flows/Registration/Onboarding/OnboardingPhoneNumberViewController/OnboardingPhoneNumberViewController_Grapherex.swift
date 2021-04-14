//
//  Copyright (c) 2018 SkyTech. All rights reserved.
// 

import UIKit
import PromiseKit

@objc
final public class OnboardingPhoneNumberViewController_Grapherex: OWSViewController {
    
    
    public var onboardingController: OnboardingController_Grapherex!
    // MARK: -
    private var spacing: CGFloat = -40
    
    @IBOutlet private var illustrationView: UIImageView! {
        didSet {
            illustrationView.image = UIImage(named: "SignNumber")
            illustrationView.contentMode = .scaleAspectFit
        }}
    @IBOutlet private var phoneNumberFormView: UIView! {
        didSet {
            phoneNumberFormView.backgroundColor = .st_neutralGrayMessege
            phoneNumberFormView.layer.cornerRadius = 10
        }}
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text =  NSLocalizedString("ONBOARDING_PHONE_NUMBER_TITLE_new", comment: "Title of the 'onboarding phone number' view.")
            titleLabel.accessibilityIdentifier = "onboarding.phoneNumber." + "titleLabel"
            titleLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
        }}
    
    @IBOutlet private var bottomSpacer: NSLayoutConstraint!
    @IBOutlet private var spacer: NSLayoutConstraint!
    @IBOutlet private var buttonsView: UIView!
    
    @IBOutlet private var callingCodeLabel: UILabel! {
        didSet {
            callingCodeLabel.textColor = Theme.lightThemePrimaryColor
            callingCodeLabel.font = UIFont.ows_dynamicTypeBodyClamped
            callingCodeLabel.isUserInteractionEnabled = true
            callingCodeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCodeTapped)))
            callingCodeLabel.accessibilityIdentifier = "onboarding.phoneNumber." + "callingCodeLabel"
        }}
    
    @IBOutlet private var phoneNumberTextField: UITextField! {
        didSet {
            phoneNumberTextField.borderStyle = .none
            phoneNumberTextField.backgroundColor = .clear
            phoneNumberTextField.textAlignment = .left
            phoneNumberTextField.delegate = self
            phoneNumberTextField.keyboardType = .numberPad
            phoneNumberTextField.textColor = Theme.lightThemePrimaryColor
            phoneNumberTextField.font = UIFont.ows_dynamicTypeBodyClamped
            phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            phoneNumberTextField.accessibilityIdentifier = "onboarding.phoneNumber." + "phoneNumberTextField"
        }}
    
    @IBOutlet private var sendButton: STPrimaryButton! {
        didSet {
            sendButton.accessibilityIdentifier = "onboarding.phoneNumber." + "nextButton"
            sendButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
            sendButton.setTitle(
                NSLocalizedString("ONBOARDING_PHONE_NUMBER_SEND",
                                  comment: ""),
                for: .normal)
        }}
    @IBOutlet private var signUpButton: STGhostButton!{
        didSet {
            // height is 0
            signUpButton.isHidden = true
            signUpButton.setTitle(
                NSLocalizedString("ONBOARDING_PHONE_NUMBER_SIGNUP",
                                  comment: ""),
                for: .normal)
        }}
    @IBOutlet private var forgotPasswordButton: STGhostButton!{
        didSet {
            // height is 0
            forgotPasswordButton.isHidden = true
            forgotPasswordButton.setTitle(
                NSLocalizedString("ONBOARDING_PHONE_NUMBER_FORGOTRASSWORD",
                                  comment: ""),
                for: .normal)
        }}
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("ONBOARDING_PHONE_NUMBER_SIGNUP", comment: "")
        populateDefaults()
        view.backgroundColor = Theme.backgroundColor
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        setupKeyboardNotifications()
        AnalyticsService.log(event: .signUpScreenOpened, parameters: nil)
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
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        if isKeyboardShowing {
            let window = UIApplication.shared.keyWindow
            let bottomPadding: CGFloat = window?.safeAreaInsets.bottom ?? 0
            
            spacer.isActive = false
            spacer.constant = keyboardFrame.height
                - buttonsView.frame.height
                - bottomPadding + 16
                - abs(bottomSpacer.constant)
            spacer.isActive = true
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
            
        } else {
            spacer.isActive = false
            spacer.constant = spacing
            spacer.isActive = true
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
    }
    // MARK: - View Lifecycle

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewState()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberTextField.becomeFirstResponder()
        if tsAccountManager.isReregistering {
            // If re-registering, pre-populate the country (country code, calling code, country name)
            // and phone number state.
            guard let phoneNumberE164 = tsAccountManager.reregistrationPhoneNumber() else {
                owsFailDebug("Could not resume re-registration; missing phone number.")
                return
            }
            tryToReregister(phoneNumberE164: phoneNumberE164)
        }
    }

    private func tryToReregister(phoneNumberE164: String) {
        guard phoneNumberE164.count > 0 else {
            owsFailDebug("Could not resume re-registration; invalid phoneNumberE164.")
            return
        }
        guard let parsedPhoneNumber = PhoneNumber(fromE164: phoneNumberE164) else {
            owsFailDebug("Could not resume re-registration; couldn't parse phoneNumberE164.")
            return
        }
        guard let callingCodeNumeric = parsedPhoneNumber.getCountryCode() else {
            owsFailDebug("Could not resume re-registration; missing callingCode.")
            return
        }
        let callingCode = "\(COUNTRY_CODE_PREFIX)\(callingCodeNumeric)"
        let countryCodes: [String] =
            PhoneNumberUtil.sharedThreadLocal().countryCodes(fromCallingCode: callingCode)
        guard let countryCode = countryCodes.first else {
            owsFailDebug("Could not resume re-registration; unknown countryCode.")
            return
        }
        guard let countryName = PhoneNumberUtil.countryName(fromCountryCode: countryCode) else {
            owsFailDebug("Could not resume re-registration; unknown countryName.")
            return
        }
        if !phoneNumberE164.hasPrefix(callingCode) {
            owsFailDebug("Could not resume re-registration; non-matching calling code.")
            return
        }
        let phoneNumberWithoutCallingCode = phoneNumberE164.substring(from: callingCode.count)

        guard countryCode.count > 0 else {
            owsFailDebug("Invalid country code.")
            return
        }
        guard countryName.count > 0 else {
            owsFailDebug("Invalid country name.")
            return
        }
        guard callingCode.count > 0 else {
            owsFailDebug("Invalid calling code.")
            return
        }
        
        let countryState = OnboardingCountryState(countryName: countryName, callingCode: callingCode, countryCode: countryCode)
        onboardingController.update(countryState: countryState)
        
        phoneNumberTextField.text = phoneNumberWithoutCallingCode
        
        // Don't let user edit their phone number while re-registering.
        phoneNumberTextField.isEnabled = false
        
        updateViewState()
        
        // Trigger the formatting logic with a no-op edit.
        _ = textField(phoneNumberTextField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
    }
    
    // MARK: -
    
    private var callingCode: String {
        get {
            AssertIsOnMainThread()
            
            return onboardingController!.countryState.callingCode
        }
    }
    private var countryCode: String {
        get {
            AssertIsOnMainThread()
            
            return onboardingController!.countryState.countryCode
        }
    }
    
    private func populateDefaults() {
        if let lastRegisteredPhoneNumber = OnboardingController.lastRegisteredPhoneNumber(),
            lastRegisteredPhoneNumber.count > 0 {
            phoneNumberTextField.text = lastRegisteredPhoneNumber
        } else if let phoneNumber = onboardingController!.phoneNumber {
            phoneNumberTextField.text = phoneNumber.userInput
        }

        updateViewState()

        // Trigger the formatting logic with a no-op edit.
        _ = textField(phoneNumberTextField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
    }

    private func updateViewState() {
        AssertIsOnMainThread()
        
        callingCodeLabel.text = callingCode

        self.phoneNumberTextField.placeholder = ViewControllerUtils.examplePhoneNumber(forCountryCode: countryCode, callingCode: callingCode, includeExampleLabel: true)
    }
    
    // MARK: - Events
    @objc func countryCodeTapped(sender: UIGestureRecognizer) {
        guard sender.state == .recognized else {
            return
        }
        showCountryPicker()
    }
    
    @objc func nextPressed() {
        Logger.info("")
        view.endEditing(true)
        parseAndTryToRegister()
    }

    // MARK: - Country Picker

    private func showCountryPicker() {
        guard !tsAccountManager.isReregistering else {
            return
        }

        let countryCodeController = CountryCodeViewController()
        countryCodeController.countryCodeDelegate = self
        countryCodeController.interfaceOrientationMask = UIDevice.current.isIPad ? .all : .portrait
        let navigationController = OWSNavigationController(rootViewController: countryCodeController)
        self.present(navigationController, animated: true, completion: nil)
    }

    // MARK: - RegisteronboardingController

    private func parseAndTryToRegister() {
        guard let phoneNumberText = phoneNumberTextField.text?.ows_stripped(),
            phoneNumberText.count > 0 else {

                OWSActionSheets.showActionSheet(title:
                    NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_TITLE",
                                      comment: "Title of alert indicating that users needs to enter a phone number to register."),
                                                message:
                    NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_MESSAGE",
                                      comment: "Message of alert indicating that users needs to enter a phone number to register."))
                return
        }
        
        let phoneNumber = "\(callingCode)\(phoneNumberText)"
        guard let localNumber = PhoneNumber.tryParsePhoneNumber(fromUserSpecifiedText: phoneNumber),
            localNumber.toE164().count > 0,
            PhoneNumberValidator().isValidForRegistration(phoneNumber: localNumber) else {
                OWSActionSheets.showActionSheet(title:
                    NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_TITLE",
                                      comment: "Title of alert indicating that users needs to enter a valid phone number to register."),
                                                message:
                    NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_MESSAGE",
                                      comment: "Message of alert indicating that users needs to enter a valid phone number to register."))
                return
        }
        let e164PhoneNumber = localNumber.toE164()

        onboardingController.update(phoneNumber: OnboardingPhoneNumber(e164: e164PhoneNumber, userInput: phoneNumberText))
        onboardingController.requestVerification(fromViewController: self, isSMS: true)
    }
    
    func changeStyle(isFilled: Bool) {
        sendButton.handleEnabled(isFilled)
    }
    
    private func applyPhoneNumberFormatting() {
        AssertIsOnMainThread()
        ViewControllerUtils.reformatPhoneNumber(phoneNumberTextField, callingCode: callingCode)
    }
}

// MARK: -

extension OnboardingPhoneNumberViewController_Grapherex: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as String
        changeStyle(isFilled: newString.count >= 6)
        
        // If ViewControllerUtils applied the edit on our behalf, inform UIKit
        // so the edit isn't applied twice.
        return ViewControllerUtils.phoneNumber(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string,
            callingCode: callingCode)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        applyPhoneNumberFormatting()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parseAndTryToRegister()
        return false
    }
}

// MARK: -

extension OnboardingPhoneNumberViewController_Grapherex: CountryCodeViewControllerDelegate {
    public func countryCodeViewController(_ vc: CountryCodeViewController, didSelectCountryCode countryCode: String, countryName: String, callingCode: String) {
        guard countryCode.count > 0 else {
            owsFailDebug("Invalid country code.")
            return
        }
        guard countryName.count > 0 else {
            owsFailDebug("Invalid country name.")
            return
        }
        guard callingCode.count > 0 else {
            owsFailDebug("Invalid calling code.")
            return
        }

        let countryState = OnboardingCountryState(countryName: countryName, callingCode: callingCode, countryCode: countryCode)

        onboardingController.update(countryState: countryState)

        updateViewState()

            // Trigger the formatting logic with a no-op edit.
        _ = textField(phoneNumberTextField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
    }
}
