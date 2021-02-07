//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import UIKit
import PromiseKit

@objc
public class OnboardingVerificationViewController_Grapherex: OWSViewController {

    private enum CodeState {
        case sent
        case readyForResend
        case resent
    }

    // MARK: -
    @objc public var onboardingController: OnboardingController_Grapherex!
    private var codeState = CodeState.sent
    
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var spacer: NSLayoutConstraint!
    @IBOutlet var codeStateLink: STGhostButton! {
        didSet {
            codeStateLink.accessibilityIdentifier = "onboarding.verification." + "codeStateLink"
            codeStateLink.titleLabel?.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
            codeStateLink.addTarget(self, action: #selector(resendCodeLinkTapped), for: .touchUpInside)
            codeStateLink.setTitle(NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_BY_SMS_BUTTON",
            comment: "Label for link that can be used when the original code did not arrive."), for: .normal)
        }
    }
    
    @IBOutlet var onboardingCodeView: OnboardingCodeView_Grapherex!
    @IBOutlet var errorLabel: UILabel! {
        didSet {
            errorLabel.textColor = .ows_accentRed
            errorLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 10)
            errorLabel.textAlignment = .center
            errorLabel.autoSetDimension(.height, toSize: errorLabel.font.lineHeight)
            errorLabel.accessibilityIdentifier = "onboarding.verification." + "errorLabel"
            errorLabel.text = NSLocalizedString("ONBOARDING_VERIFICATION_INVALID_CODE_new",
            comment: "Label indicating that the verification code is incorrect in the 'onboarding verification' view.")
        }}
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text =  NSLocalizedString("ONBOARDING_PHONE_NUMBER_TITLE_new", comment: "Title of the 'onboarding phone number' view.")
            titleLabel.accessibilityIdentifier = "onboarding.phoneNumber." + "titleLabel"
            titleLabel.font = UIFont.st_sfUiTextRegularFont(withSize: 16)
            titleLabel.textAlignment = .center
        }}

    override public func viewDidLoad() {
       view.backgroundColor = Theme.backgroundColor

        onboardingCodeView.delegate = self
        
        startCodeCountdown()

        setHasInvalidCode(false)
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        setupKeyboardNotifications()
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
        let bottomPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        
        if isKeyboardShowing {
            bottomSpaceConstraint.isActive = false
            bottomSpaceConstraint.constant = keyboardFrame.height - bottomPadding + 16
            bottomSpaceConstraint.isActive = true
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
            
        } else {
            bottomSpaceConstraint.isActive = false
            bottomSpaceConstraint.constant = 16
            bottomSpaceConstraint.isActive = true
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
            
        }
    }

     // MARK: - Code State

    private let countdownDuration: TimeInterval = 30
    private var codeCountdownTimer: Timer?
    private var codeCountdownStart: NSDate?

    deinit {
        codeCountdownTimer?.invalidate()
    }

    private func startCodeCountdown() {
        codeCountdownStart = NSDate()
        codeCountdownTimer = Timer.weakScheduledTimer(withTimeInterval: 0.25, target: self, selector: #selector(codeCountdownTimerFired), userInfo: nil, repeats: true)
    }

    @objc
    public func codeCountdownTimerFired() {
        guard let codeCountdownStart = codeCountdownStart else {
            owsFailDebug("Missing codeCountdownStart.")
            return
        }
        guard let codeCountdownTimer = codeCountdownTimer else {
            owsFailDebug("Missing codeCountdownTimer.")
            return
        }

        let countdownInterval = abs(codeCountdownStart.timeIntervalSinceNow)

        guard countdownInterval < countdownDuration else {
            // Countdown complete.
            codeCountdownTimer.invalidate()
            self.codeCountdownTimer = nil

            if codeState != .sent {
                owsFailDebug("Unexpected codeState: \(codeState)")
            }
            codeState = .readyForResend
            return
        }
    }

    // MARK: - View Lifecycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = onboardingCodeView.becomeFirstResponder()
    }

    // MARK: - Events

    @objc func backLinkTapped() {
        Logger.info("")

        self.navigationController?.popViewController(animated: true)
    }

    @objc func resendCodeLinkTapped() {
        Logger.info("")

        switch codeState {
        case .sent:
            showError()
        case .readyForResend, .resent:
            showResendActionSheet()
        }
    }

    private func showError() {
        Logger.info("")
        OWSActionSheets.showActionSheet(title: NSLocalizedString("REGISTER_RATE_BODY", comment: ""))
    }

    private func showResendActionSheet() {
        Logger.info("")
        let actionSheet = ActionSheetController(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_ALERT_TITLE",
                                                                     comment: "Title for the 'resend code' alert in the 'onboarding verification' view."),
                                            message: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_ALERT_MESSAGE",
                                                                       comment: "Message for the 'resend code' alert in the 'onboarding verification' view."))
        actionSheet.addAction(ActionSheetAction(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_BY_SMS_BUTTON",
                                                                     comment: "Label for the 'resend code by SMS' button in the 'onboarding verification' view."),
                                            style: .default) { _ in
                                                self.onboardingController.requestVerification(fromViewController: self, isSMS: true)
        })
//        actionSheet.addAction(ActionSheetAction(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_BY_VOICE_BUTTON",
//                                                                     comment: "Label for the 'resend code by voice' button in the 'onboarding verification' view."),
//                                            style: .default) { _ in
//                                                self.onboardingController.requestVerification(fromViewController: self, isSMS: false)
//        })
        actionSheet.addAction(OWSActionSheets.cancelAction)

        self.presentActionSheet(actionSheet)
    }

    private func tryToVerify() {
        Logger.info("")

        guard onboardingCodeView.isComplete else {
            self.setHasInvalidCode(false)
            return
        }

        setHasInvalidCode(false)

        onboardingController.update(verificationCode: onboardingCodeView.verificationCode)

        // Temporarily hide the "resend link" button during the verification attempt.
        codeStateLink?.layer.opacity = 0.05

        onboardingController.submitVerification(fromViewController: self, completion: { [weak self] (outcome) in
            self?.codeStateLink?.layer.opacity = 1

            if outcome == .invalidVerificationCode {
                self?.setHasInvalidCode(true)
            }
            if outcome == .success {
                self?.onboardingCodeView.addBorder(with: .st_accentGreen)
                self?.errorLabel.textColor = .st_accentGreen
                self?.errorLabel.text = NSLocalizedString("ONBOARDING_VERIFICATION_VALID_CODE_new",
                comment: "Label indicating that the verification code is incorrect in the 'onboarding verification' view.")
                self?.errorLabel.isHidden = false
            }
        })
    }

    private func setHasInvalidCode(_ value: Bool) {
        onboardingCodeView.setHasError(value)
        errorLabel.isHidden = !value
    }

    @objc
    public func setVerificationCodeAndTryToVerify(_ verificationCode: String) {
        AssertIsOnMainThread()

        let filteredCode = verificationCode.digitsOnly
        guard filteredCode.count > 0 else {
            owsFailDebug("Invalid code: \(verificationCode)")
            return
        }

        onboardingCodeView.set(verificationCode: filteredCode)
    }
}

// MARK: -

extension OnboardingVerificationViewController_Grapherex: OnboardingCodeViewDelegate {
    public func codeViewDidChange() {
        AssertIsOnMainThread()

        setHasInvalidCode(false)

        tryToVerify()
    }
}
