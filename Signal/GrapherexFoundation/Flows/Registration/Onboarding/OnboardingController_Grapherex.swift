//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit
import PromiseKit

@objc
public class OnboardingNavigationController_Grapherex: OWSNavigationController {
    let onboardingController: OnboardingController_Grapherex

    @objc
    public init(onboardingController: OnboardingController_Grapherex) {
        self.onboardingController = onboardingController
        super.init()
        if let nextMilestone = onboardingController.nextMilestone {
            setViewControllers([onboardingController.nextViewController(milestone: nextMilestone)], animated: false)
        }
    }
}

@objc
public class OnboardingController_Grapherex: NSObject {

    public enum OnboardingMode {
        case provisioning
        case registering
    }

    public static let defaultOnboardingMode: OnboardingMode = UIDevice.current.isIPad ? .provisioning : .registering
    public var onboardingMode: OnboardingMode
    public var isOnboardingModeOverriden: Bool {
        return onboardingMode != OnboardingController_Grapherex.defaultOnboardingMode
    }

    public class func ascertainOnboardingMode() -> OnboardingMode {
        if tsAccountManager.isRegisteredPrimaryDevice {
            return .registering
        } else if tsAccountManager.isRegistered {
            return .provisioning
        } else {
            return defaultOnboardingMode
        }
    }

    convenience override init() {
        let onboardingMode = OnboardingController_Grapherex.ascertainOnboardingMode()
        self.init(onboardingMode: onboardingMode)
    }

    init(onboardingMode: OnboardingMode) {
        self.onboardingMode = onboardingMode
        super.init()
        Logger.info("onboardingMode: \(onboardingMode), requiredMilestones: \(requiredMilestones), completedMilestones: \(completedMilestones), nextMilestone: \(nextMilestone as Optional)")
    }

    // MARK: -

    enum OnboardingMilestone {
        case verifiedPhoneNumber
        case verifiedLinkedDevice
        case restorePin
        case setupProfile
        case setupPin
    }

    var requiredMilestones: [OnboardingMilestone] {
        switch onboardingMode {
        case .provisioning:
            return [.verifiedLinkedDevice]
        case .registering:
            var milestones: [OnboardingMilestone] = [.verifiedPhoneNumber, .setupProfile]

            let hasPendingPinRestoration = databaseStorage.read {
                KeyBackupService.hasPendingRestoration(transaction: $0)
            }

            if hasPendingPinRestoration {
                milestones.insert(.restorePin, at: 0)
            }

            if FeatureFlags.pinsForNewUsers || hasPendingPinRestoration {
                let hasBackupKeyRequestFailed = databaseStorage.read {
                    KeyBackupService.hasBackupKeyRequestFailed(transaction: $0)
                }

                if hasBackupKeyRequestFailed {
                    Logger.info("skipping setupPin since a previous request failed")
                } else if hasPendingPinRestoration {
                    milestones.insert(.setupPin, at: 1)
                } else {
                    milestones.append(.setupPin)
                }
            }

            return milestones
        }
    }

    @objc
    var isComplete: Bool {
        guard !tsAccountManager.isOnboarded() else {
            Logger.debug("previously completed onboarding")
            return true
        }

        guard nextMilestone != nil else {
            Logger.debug("no remaining milestones")
            return true
        }

        return false
    }

    var nextMilestone: OnboardingMilestone? {
        requiredMilestones.first { !completedMilestones.contains($0) }
    }

    var completedMilestones: [OnboardingMilestone] {
        var milestones: [OnboardingMilestone] = []

        if tsAccountManager.isRegisteredPrimaryDevice {
            milestones.append(.verifiedPhoneNumber)
        } else if tsAccountManager.isRegistered {
            milestones.append(.verifiedLinkedDevice)
        }

        if profileManager.hasProfileName {
            milestones.append(.setupProfile)
        }

        // TODO: SKYTECH: Revert this to enable pin-code protection.
        #if true
            milestones.append(.restorePin)
            milestones.append(.setupPin)
        #else
            if KeyBackupService.hasMasterKey {
                milestones.append(.restorePin)
                milestones.append(.setupPin)
            }
        #endif

        return milestones
    }

    @objc
    public func markAsOnboarded() {
        guard !tsAccountManager.isOnboarded() else { return }
        self.databaseStorage.asyncWrite {
            Logger.info("completed onboarding")
            self.tsAccountManager.setIsOnboarded(true, transaction: $0)
        }
    }

    func showNextMilestone(navigationController: UINavigationController) {
        guard let nextMilestone = nextMilestone else {
            SignalApp.shared().showConversationSplitView()
            markAsOnboarded()
            return
        }

        let viewController = nextViewController(milestone: nextMilestone)

        // *replace* the existing VC's. There's no going back once you've passed a milestone.
        navigationController.setViewControllers([viewController], animated: true)
    }

    fileprivate func nextViewController(milestone: OnboardingMilestone) -> UIViewController {
        Logger.info("milestone: \(milestone)")
        switch milestone {
        case .verifiedPhoneNumber, .verifiedLinkedDevice:
            return OnboardingSplashViewController_Grapherex(onboardingController: self)
        case .setupProfile:
            return buildProfileRegistartionViewController()
        case .restorePin:
            return Onboarding2FAViewController_Grapherex(onboardingController: self, isUsingKBS: true)
        case .setupPin:
            return buildPinSetupViewController()
        }
    }

    // MARK: - Transitions

    public func onboardingSplashDidComplete(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        let view = OnboardingPermissionsViewController_Grapherex(onboardingController: self)
        viewController.navigationController?.pushViewController(view, animated: true)
    }

    public func onboardingSplashRequestedModeSwitch(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        let view = OnboardingModeSwitchConfirmationViewController_Grapherex(onboardingController: self)
        viewController.navigationController?.pushViewController(view, animated: true)
    }

    public func toggleModeSwitch(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        let wasOverridden = isOnboardingModeOverriden
        switch onboardingMode {
        case .provisioning:
            onboardingMode  = .registering
        case .registering:
            onboardingMode = .provisioning
        }

        if wasOverridden {
            onboardingMode = OnboardingController_Grapherex.defaultOnboardingMode
            viewController.navigationController?.popToRootViewController(animated: true)
        } else {
            let view = OnboardingPermissionsViewController_Grapherex(onboardingController: self)
            viewController.navigationController?.pushViewController(view, animated: true)
        }
    }

    public func onboardingPermissionsWasSkipped(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        guard let navigationController = viewController.navigationController else {
            owsFailDebug("navigationController was unexpectedly nil")
            return
        }

        pushStartDeviceRegistrationView(onto: navigationController)
    }

    public func onboardingPermissionsDidComplete(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        guard let navigationController = viewController.navigationController else {
            owsFailDebug("navigationController was unexpectedly nil")
            return
        }

        pushStartDeviceRegistrationView(onto: navigationController)
    }

    private func pushStartDeviceRegistrationView(onto navigationController: UINavigationController) {
        AssertIsOnMainThread()

        if onboardingMode == .provisioning {
            let provisioningController = ProvisioningController_Grapherex(onboardingController: self)
            let prepViewController = SecondaryLinkingPrepViewController_Grapherex(provisioningController: provisioningController)
            navigationController.pushViewController(prepViewController, animated: true)
        } else {
            let view = UIStoryboard.makeController(OnboardingPhoneNumberViewController_Grapherex.self)
            view.onboardingController = self
            navigationController.pushViewController(view, animated: true)
        }
    }

    public func requestingVerificationDidSucceed(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")
        
        if !(viewController.navigationController?.topViewController is OnboardingVerificationViewController) {
            let view = UIStoryboard.makeController(OnboardingVerificationViewController_Grapherex.self)
            view.onboardingController = self
            viewController.navigationController?.pushViewController(view, animated: true)
        }
    }

    public func onboardingDidRequireCaptcha(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        guard let navigationController = viewController.navigationController else {
            owsFailDebug("Missing navigationController.")
            return
        }

        // The service could demand CAPTCHA from the "phone number" view or later
        // from the "code verification" view.  The "Captcha" view should always appear
        // immediately after the "phone number" view.
        while navigationController.viewControllers.count > 1 &&
            !(navigationController.topViewController is OnboardingPhoneNumberViewController) {
                navigationController.popViewController(animated: false)
        }

        let view = OnboardingCaptchaViewController_Grapherex(onboardingController: self)
        navigationController.pushViewController(view, animated: true)
    }

    @objc
    public func verificationDidComplete(fromView view: UIViewController) {
        AssertIsOnMainThread()
        Logger.info("")
        guard let navigationController = view.navigationController else {
            owsFailDebug("navigationController was unexpectedly nil")
            return
        }

        // At this point, the user has been prompted for contact access
        // and has valid service credentials.
        // We start the contact fetch/intersection now so that by the time
        // they get to conversation list we can show meaningful contact in
        // the suggested contact bubble.
        contactsManagerImpl.fetchSystemContactsOnceIfAlreadyAuthorized()

        showNextMilestone(navigationController: navigationController)
    }

    public func linkingDidComplete(from viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else {
            owsFailDebug("navigationController was unexpectedly nil")
            return
        }

        showNextMilestone(navigationController: navigationController)
    }

    func buildProfileRegistartionViewController() -> UIViewController {
        let view = UIStoryboard.makeController(ProfileRegistrationViewController.self)
        view.updateСompletionHandler({ [weak self] profileViewController in
            if let navController = profileViewController.navigationController {
                self?.showNextMilestone(navigationController: navController)
            }
        })
        return view
    }

    func buildPinSetupViewController() -> PinSetupViewController {
        return PinSetupViewController.creating { [weak self] pinSetupVC, _ in
            guard let self = self else { return }

            guard let navigationController = pinSetupVC.navigationController else {
                owsFailDebug("navigationController was unexpectedly nil")
                return
            }

            self.showNextMilestone(navigationController: navigationController)
        }
    }

    public func onboardingDidRequire2FAPin(viewController: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        guard let navigationController = viewController.navigationController else {
            owsFailDebug("Missing navigationController")
            return
        }

        guard !(navigationController.topViewController is Onboarding2FAViewController) else {
            // 2fa view is already presented, we don't need to push it again.
            return
        }

        let view = Onboarding2FAViewController_Grapherex(onboardingController: self, isUsingKBS: kbsAuth != nil)
        navigationController.pushViewController(view, animated: true)
    }

    @objc
    public func profileWasSkipped(fromView view: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        showConversationSplitView(view: view)
    }

    @objc
    public func profileDidComplete(fromView view: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        showConversationSplitView(view: view)
    }

    private func showConversationSplitView(view: UIViewController) {
        AssertIsOnMainThread()

        guard let navigationController = view.navigationController else {
            owsFailDebug("Missing navigationController")
            return
        }

        // In production, this view will never be presented in a modal.
        // During testing (debug UI, etc.), it may be a modal.
        let isModal = navigationController.presentingViewController != nil
        if isModal {
            view.dismiss(animated: true, completion: {
                SignalApp.shared().showConversationSplitView()
            })
        } else {
            SignalApp.shared().showConversationSplitView()
        }
    }

    // MARK: - State

    public private(set) var countryState: OnboardingCountryState = .defaultValue

    public private(set) var phoneNumber: OnboardingPhoneNumber?

    public private(set) var captchaToken: String?

    public private(set) var verificationCode: String?

    public private(set) var twoFAPin: String?

    private var kbsAuth: RemoteAttestationAuth?

    public private(set) var verificationRequestCount: UInt = 0

    @objc
    public func update(countryState: OnboardingCountryState) {
        AssertIsOnMainThread()

        self.countryState = countryState
    }

    @objc
    public func update(phoneNumber: OnboardingPhoneNumber) {
        AssertIsOnMainThread()

        self.phoneNumber = phoneNumber
    }

    @objc
    public func update(captchaToken: String) {
        AssertIsOnMainThread()

        self.captchaToken = captchaToken
    }

    @objc
    public func update(verificationCode: String) {
        AssertIsOnMainThread()

        self.verificationCode = verificationCode
    }

    @objc
    public func update(twoFAPin: String) {
        AssertIsOnMainThread()

        self.twoFAPin = twoFAPin
    }

    // MARK: - Debug

    private static let kKeychainService_LastRegistered = "kKeychainService_LastRegistered"
    private static let kKeychainKey_LastRegisteredCountryCode = "kKeychainKey_LastRegisteredCountryCode"
    private static let kKeychainKey_LastRegisteredPhoneNumber = "kKeychainKey_LastRegisteredPhoneNumber"

    private class func debugValue(forKey key: String) -> String? {
        AssertIsOnMainThread()

        guard OWSIsDebugBuild() else {
            return nil
        }

        do {
            let value = try CurrentAppContext().keychainStorage().string(forService: kKeychainService_LastRegistered, key: key)
            return value
        } catch {
            // The value may not be present in the keychain.
            return nil
        }
    }

    private class func setDebugValue(_ value: String, forKey key: String) {
        AssertIsOnMainThread()

        guard OWSIsDebugBuild() else {
            return
        }

        do {
            try CurrentAppContext().keychainStorage().set(string: value, service: kKeychainService_LastRegistered, key: key)
        } catch {
            owsFailDebug("Error: \(error)")
        }
    }

    public class func lastRegisteredCountryCode() -> String? {
        return debugValue(forKey: kKeychainKey_LastRegisteredCountryCode)
    }

    private class func setLastRegisteredCountryCode(value: String) {
        setDebugValue(value, forKey: kKeychainKey_LastRegisteredCountryCode)
    }

    public class func lastRegisteredPhoneNumber() -> String? {
        return debugValue(forKey: kKeychainKey_LastRegisteredPhoneNumber)
    }

    private class func setLastRegisteredPhoneNumber(value: String) {
        setDebugValue(value, forKey: kKeychainKey_LastRegisteredPhoneNumber)
    }

    // MARK: - Registration

    public func requestVerification(fromViewController: UIViewController, isSMS: Bool) {
        AssertIsOnMainThread()

        guard let phoneNumber = phoneNumber else {
            owsFailDebug("Missing phoneNumber.")
            return
        }

        // We eagerly update this state, regardless of whether or not the
        // registration request succeeds.
        OnboardingController_Grapherex.setLastRegisteredCountryCode(value: countryState.countryCode)
        OnboardingController_Grapherex.setLastRegisteredPhoneNumber(value: phoneNumber.userInput)

        let captchaToken = self.captchaToken
        self.verificationRequestCount += 1
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController,
                                                     canCancel: false) { modal in
            firstly {
                self.accountManager.requestAccountVerification(recipientId: phoneNumber.e164,
                                                               captchaToken: captchaToken,
                                                               isSMS: isSMS)
            }.done {
                modal.dismiss {
                    self.requestingVerificationDidSucceed(viewController: fromViewController)
                }
            }.catch { error in
                Logger.error("Error: \(error)")
                modal.dismiss {
                    self.requestingVerificationDidFail(viewController: fromViewController, error: error)
                }
            }
        }
    }

    private func requestingVerificationDidFail(viewController: UIViewController, error: Error) {
        if let statusCode = error.httpStatusCode {
            switch statusCode {
            case 400:
                OWSActionSheets.showActionSheet(title: NSLocalizedString("REGISTRATION_ERROR", comment: ""),
                                                message: NSLocalizedString("REGISTRATION_NON_VALID_NUMBER", comment: ""))
                return
            case 413:
                OWSActionSheets.showActionSheet(title: nil,
                                                message: NSLocalizedString("REGISTER_RATE_LIMITING_BODY", comment: "action sheet body"))
                return
            default:
                break
            }
        }

        if case AccountServiceClientError.captchaRequired = error {
            return onboardingDidRequireCaptcha(viewController: viewController)
        }

        let nsError = error as NSError
        owsFailDebug("unexpected error: \(nsError)")
        OWSActionSheets.showActionSheet(title: nsError.localizedDescription,
                                        message: nsError.localizedRecoverySuggestion)
    }

    // MARK: - Verification

    public enum VerificationOutcome: Equatable {
        case success
        case invalidVerificationCode
        case invalid2FAPin
        case invalidV2RegistrationLockPin(remainingAttempts: UInt32)
        case exhaustedV2RegistrationLockAttempts
    }

    private var hasPendingRestoration: Bool {
        databaseStorage.read { KeyBackupService.hasPendingRestoration(transaction: $0) }
    }

    public func submitVerification(fromViewController: UIViewController,
                                   completion : @escaping (VerificationOutcome) -> Void) {
        AssertIsOnMainThread()

        // If we have credentials for KBS auth or we're trying to verify
        // after registering, we need to restore our keys from KBS.
        if kbsAuth != nil || hasPendingRestoration {
            guard let twoFAPin = twoFAPin else {
                owsFailDebug("We expected a 2fa attempt, but we don't have a code to try")
                return completion(.invalid2FAPin)
            }

            // Clear all cached values before doing restores during onboarding,
            // they could be stale from previous registrations.
            databaseStorage.write { KeyBackupService.clearKeys(transaction: $0) }
            
            KeyBackupService.restoreKeys(with: twoFAPin, and: self.kbsAuth).done {
                // If we restored successfully clear out KBS auth, the server will give it
                // to us again if we still need to do KBS operations.
                self.kbsAuth = nil

                if self.hasPendingRestoration {
                    self.accountManager.performInitialStorageServiceRestore()
                        .ensure { completion(.success) }
                } else {
                    // We've restored our keys, we can now re-run this method to post our registration token
                    self.submitVerification(fromViewController: fromViewController, completion: completion)
                }
            }.catch { error in
                guard let error = error as? KeyBackupService.KBSError else {
                    owsFailDebug("unexpected response from KBS")
                    return completion(.invalid2FAPin)
                }

                switch error {
                case .assertion:
                    owsFailDebug("unexpected response from KBS")
                    completion(.invalid2FAPin)
                case .invalidPin(let remainingAttempts):
                    completion(.invalidV2RegistrationLockPin(remainingAttempts: remainingAttempts))
                case .backupMissing:
                    // We don't have a backup for this person, it probably
                    // was deleted due to too many failed attempts. They'll
                    // have to retry after the registration lock window expires.
                    completion(.exhaustedV2RegistrationLockAttempts)
                }
            }

            return
        }

        guard let phoneNumber = phoneNumber else {
            owsFailDebug("Missing phoneNumber.")
            return
        }
        guard let verificationCode = verificationCode else {
            completion(.invalidVerificationCode)
            return
        }

        // Ensure the account manager state is up-to-date.
        //
        // TODO: We could skip this in production.
        tsAccountManager.phoneNumberAwaitingVerification = phoneNumber.e164

        let twoFAPin = self.twoFAPin
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController,
                                                     canCancel: false) { (modal) in

            self.accountManager.register(verificationCode: verificationCode, pin: twoFAPin, checkForAvailableTransfer: false)
                                                            .then { _ -> Promise<Void> in
                                                                // Re-enable 2FA and RegLock with the registered pin, if any
                                                                if let pin = twoFAPin {
                                                                    self.databaseStorage.write { transaction in
                                                                        OWS2FAManager.shared.markEnabled(pin: pin, transaction: transaction)
                                                                    }

                                                                    if OWS2FAManager.shared.mode == .V2 {
                                                                        return OWS2FAManager.shared.enableRegistrationLockV2()
                                                                    }
                                                                }

                                                                return Promise.value(())
                                                            }.done { (_) in
                                                                completion(.success)
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ) {
                                                                    modal.dismiss(completion: {
                                                                        self.verificationDidComplete(fromView: fromViewController)
                                                                    })
                                                                }
                                                            }.catch({ (error) in
                                                                Logger.error("Error: \(error)")

                                                                DispatchQueue.main.async {
                                                                    modal.dismiss(completion: {
                                                                        self.verificationFailed(fromViewController: fromViewController,
                                                                                                error: error as NSError,
                                                                                                completion: completion)
                                                                    })
                                                                }
                                                            })
        }
    }

    private func verificationFailed(fromViewController: UIViewController, error: NSError,
                                    completion : @escaping (VerificationOutcome) -> Void) {
        AssertIsOnMainThread()

        if error.domain == OWSSignalServiceKitErrorDomain &&
            error.code == OWSErrorCode.registrationMissing2FAPIN.rawValue {

            Logger.info("Missing 2FA PIN.")

            // If we were provided KBS auth, we'll need to re-register using reg lock v2,
            // store this for that path.
            kbsAuth = error.userInfo[TSRemoteAttestationAuthErrorKey] as? RemoteAttestationAuth

            // Since we were told we need 2fa, clear out any stored KBS keys so we can
            // do a fresh verification.
            SDSDatabaseStorage.shared.write { KeyBackupService.clearKeys(transaction: $0) }

            completion(.invalid2FAPin)

            onboardingDidRequire2FAPin(viewController: fromViewController)
        } else {
            if error.domain == OWSSignalServiceKitErrorDomain &&
                error.code == OWSErrorCode.userError.rawValue {
                completion(.invalidVerificationCode)
            }

            Logger.verbose("error: \(error.domain) \(error.code)")
            OWSActionSheets.showActionSheet(title: NSLocalizedString("REGISTRATION_VERIFICATION_FAILED_TITLE", comment: "Alert view title"),
                                message: error.localizedDescription,
                                fromViewController: fromViewController)
        }
    }
}
