//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit
import PromiseKit

@objc
public class OnboardingVerificationViewController_old: OnboardingBaseViewController {

    private enum CodeState {
        case sent
        case readyForResend
        case resent
    }

    // MARK: -

    private var codeState = CodeState.sent

    private var titleLabel: UILabel?
    private var backLink: UIView?
    private let onboardingCodeView = OnboardingCodeView_Grapherex()
    private var codeStateLink: OWSFlatButton?
    private let errorLabel = UILabel()

    @objc
    public func hideBackLink() {
        backLink?.isHidden = true
    }

    override public func loadView() {
        view = UIView()
        view.addSubview(primaryView)
        primaryView.autoPinEdgesToSuperviewEdges()

        view.backgroundColor = Theme.backgroundColor

        let titleLabel = self.titleLabel(text: "")
        self.titleLabel = titleLabel
        titleLabel.accessibilityIdentifier = "onboarding.verification." + "titleLabel"

        let backLink = self.linkButton(title: NSLocalizedString("ONBOARDING_VERIFICATION_BACK_LINK",
                                                                comment: "Label for the link that lets users change their phone number in the onboarding views."),
                                       selector: #selector(backLinkTapped))
        self.backLink = backLink
        backLink.accessibilityIdentifier = "onboarding.verification." + "backLink"

        onboardingCodeView.delegate = self

        errorLabel.text = NSLocalizedString("ONBOARDING_VERIFICATION_INVALID_CODE",
                                            comment: "Label indicating that the verification code is incorrect in the 'onboarding verification' view.")
        errorLabel.textColor = .ows_accentRed
        errorLabel.font = UIFont.ows_dynamicTypeBodyClamped.ows_semibold
        errorLabel.textAlignment = .center
        errorLabel.autoSetDimension(.height, toSize: errorLabel.font.lineHeight)
        errorLabel.accessibilityIdentifier = "onboarding.verification." + "errorLabel"

        // Wrap the error label in a row so that we can show/hide it without affecting view layout.
        let errorRow = UIView()
        errorRow.addSubview(errorLabel)
        errorLabel.autoPinEdgesToSuperviewEdges()

        let codeStateLink = self.linkButton(title: "",
                                             selector: #selector(resendCodeLinkTapped))
        codeStateLink.enableMultilineLabel()
        self.codeStateLink = codeStateLink
        codeStateLink.accessibilityIdentifier = "onboarding.verification." + "codeStateLink"

        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        let compressableBottomMargin = UIView.vStretchingSpacer(minHeight: 16, maxHeight: primaryLayoutMargins.bottom)
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView.spacer(withHeight: 12),
            backLink,
            topSpacer,
            onboardingCodeView,
            UIView.spacer(withHeight: 12),
            errorRow,
            bottomSpacer,
            codeStateLink,
            compressableBottomMargin
            ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        primaryView.addSubview(stackView)

        // Because of the keyboard, vertical spacing can get pretty cramped,
        // so we have custom spacer logic.
        stackView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        autoPinView(toBottomOfViewControllerOrKeyboard: stackView, avoidNotch: true)

        // Ensure whitespace is balanced, so inputs are vertically centered.
        topSpacer.autoMatch(.height, to: .height, of: bottomSpacer)

        startCodeCountdown()

        updateCodeState()

        setHasInvalidCode(false)
    }

     // MARK: - Code State

    private let countdownDuration: TimeInterval = 60
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
            updateCodeState()
            return
        }

        // Update the "code state" UI to reflect the countdown.
        updateCodeState()
    }

    private func updateCodeState() {
        AssertIsOnMainThread()

        guard let codeCountdownStart = codeCountdownStart else {
            owsFailDebug("Missing codeCountdownStart.")
            return
        }
        guard let titleLabel = titleLabel else {
            owsFailDebug("Missing titleLabel.")
            return
        }
        guard let codeStateLink = codeStateLink else {
            owsFailDebug("Missing codeStateLink.")
            return
        }

        var e164PhoneNumber = ""
        if let phoneNumber = onboardingController.phoneNumber {
            e164PhoneNumber = phoneNumber.e164
        }

        let formattedPhoneNumber =
            PhoneNumber.bestEffortLocalizedPhoneNumber(withE164: e164PhoneNumber)
                .replacingOccurrences(of: " ", with: "\u{00a0}")

        // Update titleLabel
        switch codeState {
        case .sent, .readyForResend:
            titleLabel.text = String(format: NSLocalizedString("ONBOARDING_VERIFICATION_TITLE_DEFAULT_FORMAT",
                                                               comment: "Format for the title of the 'onboarding verification' view. Embeds {{the user's phone number}}."),
                                     formattedPhoneNumber)
        case .resent:
            titleLabel.text = String(format: NSLocalizedString("ONBOARDING_VERIFICATION_TITLE_RESENT_FORMAT",
                                                               comment: "Format for the title of the 'onboarding verification' view after the verification code has been resent. Embeds {{the user's phone number}}."),
                                     formattedPhoneNumber)
        }

        // Update codeStateLink
        switch codeState {
        case .sent:
            let countdownInterval = abs(codeCountdownStart.timeIntervalSinceNow)
            let countdownRemaining = max(0, countdownDuration - countdownInterval)
            let formattedCountdown = OWSFormat.formatDurationSeconds(Int(round(countdownRemaining)))
            let text = String(format: NSLocalizedString("ONBOARDING_VERIFICATION_CODE_COUNTDOWN_FORMAT",
                                                        comment: "Format for the label of the 'sent code' label of the 'onboarding verification' view. Embeds {{the time until the code can be resent}}."),
                              formattedCountdown)
            codeStateLink.setTitle(title: text, font: .ows_dynamicTypeBodyClamped, titleColor: Theme.secondaryTextAndIconColor)
        case .readyForResend:
            codeStateLink.setTitle(title: NSLocalizedString("ONBOARDING_VERIFICATION_ORIGINAL_CODE_MISSING_LINK",
                                                            comment: "Label for link that can be used when the original code did not arrive."),
                                   font: .ows_dynamicTypeBodyClamped,
                                   titleColor: Theme.accentBlueColor)
        case .resent:
            codeStateLink.setTitle(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESENT_CODE_MISSING_LINK",
                                                            comment: "Label for link that can be used when the resent code did not arrive."),
                                   font: .ows_dynamicTypeBodyClamped,
                                   titleColor: Theme.accentBlueColor)
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
            // Ignore taps until the countdown expires.
            break
        case .readyForResend, .resent:
            showResendActionSheet()
        }
    }

    private func showResendActionSheet() {
        Logger.info("")

        let actionSheet = ActionSheetController(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_ALERT_TITLE",
                                                                     comment: "Title for the 'resend code' alert in the 'onboarding verification' view."),
                                            message: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_ALERT_MESSAGE",
                                                                       comment: "Message for the 'resend code' alert in the 'onboarding verification' view."))

        if onboardingController.verificationRequestCount > 2 {
            actionSheet.addAction(ActionSheetAction(title: NSLocalizedString("ONBOARDING_VERIFICATION_EMAIL_SIGNAL_SUPPORT",
                                                                         comment: "action sheet item shown after a number of failures to receive a verificaiton SMS during registration"),
                                                style: .default) { _ in
                ComposeSupportEmailOperation.sendEmailWithDefaultErrorHandling(supportFilter: "Signal Registration - Verification Code for iOS")
            })
        }

        actionSheet.addAction(ActionSheetAction(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_BY_SMS_BUTTON",
                                                                     comment: "Label for the 'resend code by SMS' button in the 'onboarding verification' view."),
                                            style: .default) { _ in
                                                self.onboardingController.requestVerification(fromViewController: self, isSMS: true)
        })
        actionSheet.addAction(ActionSheetAction(title: NSLocalizedString("ONBOARDING_VERIFICATION_RESEND_CODE_BY_VOICE_BUTTON",
                                                                     comment: "Label for the 'resend code by voice' button in the 'onboarding verification' view."),
                                            style: .default) { _ in
                                                self.onboardingController.requestVerification(fromViewController: self, isSMS: false)
        })
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

        onboardingController.submitVerification(fromViewController: self, completion: { (outcome) in
            self.codeStateLink?.layer.opacity = 1

            if outcome == .invalidVerificationCode {
                self.setHasInvalidCode(true)
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

extension OnboardingVerificationViewController_old: OnboardingCodeViewDelegate {
    public func codeViewDidChange() {
        AssertIsOnMainThread()

        setHasInvalidCode(false)

        tryToVerify()
    }
}
