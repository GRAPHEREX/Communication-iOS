//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit
import PromiseKit
import Contacts
import Lottie

@objc
public class OnboardingPermissionsViewController_Grapherex: OnboardingBaseViewController_Grapherex {

    private let animationView = AnimationView(name: "notificationPermission")
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = NSLocalizedString("ONBOARDING_PERMISSIONS_TITLE",
                                       comment: "Title of the 'onboarding permissions' view.")
        label.accessibilityIdentifier = "onboarding.permissions." + "titleLabel"
        label.font = UIFont.st_sfUiTextSemiboldFont(withSize: 16)
        label.textColor = Theme.primaryTextColor
        return label
    }()
    
    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = NSLocalizedString("ONBOARDING_PERMISSIONS_EXPLANATION",
                                       comment: "Explanation in the 'onboarding permissions' view.")
        label.accessibilityIdentifier = "onboarding.permissions." + "explanationLabel"
        label.font = UIFont.st_sfUiTextRegularFont(withSize: 14)
        label.textColor = .st_neutralGray
        return label
    }()
    
    private var giveAccessButton = STPrimaryButton()
    
    override public func loadView() {
        view = UIView()
        view.addSubview(primaryView)
        animationView.contentMode = .scaleAspectFill
        primaryView.autoPinEdgesToSuperviewEdges()
        view.backgroundColor = Theme.backgroundColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NAVIGATION_ITEM_SKIP_BUTTON",
                                                                                     comment: "A button to skip a view."),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(skipWasPressed))
        animationView.loopMode = .playOnce
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFit
        animationView.isUserInteractionEnabled = false
        animationView.setContentHuggingHigh()

        giveAccessButton = STPrimaryButton()
        giveAccessButton.setTitle(NSLocalizedString("ONBOARDING_PERMISSIONS_ENABLE_PERMISSIONS_BUTTON",
                                                    comment: "Label for the 'give access' button in the 'onboarding permissions' view."),
                                  for: .normal)
        giveAccessButton.addTarget(self, action: #selector(giveAccessPressed), for: .touchUpInside)
        giveAccessButton.accessibilityIdentifier = "onboarding.permissions." + "giveAccessButton"
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(animationView)
        animationView.autoCenterInSuperview()
        animationView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        animationView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        view.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 24)
        
        view.addSubview(explanationLabel)
        explanationLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 56)
        explanationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 56)
        explanationLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 20)
        
        view.addSubview(giveAccessButton)
        giveAccessButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        giveAccessButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        giveAccessButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)

    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animationView.play()
    }

    // MARK: Request Access

    private func requestAccess() {
        Logger.info("")

        requestContactsAccess().then { _ in
            return PushRegistrationManager.shared.registerUserNotificationSettings()
        }.done { [weak self] in
            guard let self = self else {
                return
            }
            self.onboardingController.onboardingPermissionsDidComplete(viewController: self)
        }
    }

    private func requestContactsAccess() -> Promise<Void> {
        Logger.info("")

        let (promise, resolver) = Promise<Void>.pending()
        CNContactStore().requestAccess(for: CNEntityType.contacts) { (granted, error) -> Void in
            if granted {
                Logger.info("Granted.")
            } else {
                Logger.error("Error: \(String(describing: error)).")
            }
            // Always fulfill.
            resolver.fulfill(())
        }
        return promise
    }

     // MARK: - Events

    @objc func skipWasPressed() {
        Logger.info("")

        onboardingController.onboardingPermissionsWasSkipped(viewController: self)
    }

    @objc func giveAccessPressed() {
        Logger.info("")

        requestAccess()
    }

    @objc func notNowPressed() {
        Logger.info("")

        onboardingController.onboardingPermissionsWasSkipped(viewController: self)
    }
}
