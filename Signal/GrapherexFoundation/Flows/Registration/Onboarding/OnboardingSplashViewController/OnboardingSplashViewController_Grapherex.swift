import UIKit
import PromiseKit
import SafariServices

@objc
public class OnboardingSplashViewController_Grapherex: OnboardingBaseViewController_Grapherex {

    let modeSwitchButton = UIButton()

    override public func loadView() {
        view = UIView()
        view.addSubview(primaryView)
        primaryView.autoPinEdgesToSuperviewEdges()
        primaryView.backgroundColor = Theme.backgroundColor
        view.backgroundColor = Theme.backgroundColor

        let logoImage = UIImage(named: "onboarding.splash.logo_black")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.minificationFilter = .trilinear
        logoImageView.layer.magnificationFilter = .trilinear
        logoImageView.accessibilityIdentifier = "onboarding.splash." + "logoImageView"

        let titleLabel = self.titleLabel(text: NSLocalizedString("ONBOARDING_SPLASH_TITLE_new", comment: "Title of the 'onboarding splash' view."))

        let stackView = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 24

        primaryView.addSubview(stackView)

        stackView.autoPinLeadingAndTrailingToSuperviewMargin()
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor, constant: -80)
        ])
        
        let linkButton = self.linkButton(title: NSLocalizedString("SETTINGS_LEGAL_TERMS_CELL", comment: ""),
                                         selector: #selector(privacyPressed))
        
        let signInButton = STPrimaryButton()
        primaryView.addSubview(signInButton)

        signInButton.setTitle(NSLocalizedString("ONBOARDING_SPLASH_BUTTON_TITLE_new",
                                                  comment: "Button title in the 'onboarding splash' view"),
                                for: .normal)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        signInButton.accessibilityIdentifier = "onboarding.splash." + "signInButton"
        
        signInButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        signInButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        primaryView.addSubview(linkButton)
        linkButton.autoSetDimension(.height, toSize: 40)
        linkButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        linkButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        linkButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)
        
        signInButton.autoPinEdge(.bottom, to: .top, of: linkButton, withOffset: -4)
    }

    // MARK: - Events
    
    @objc func privacyPressed() {
        let safariVC = SFSafariViewController(url: URL(string: "https://grapherex.com/privacy-policy/en")!)
        self.present(safariVC, animated: true)
    }

    @objc func signInPressed() {
        Logger.info("")

        onboardingController.onboardingSplashDidComplete(viewController: self)
    }
}
